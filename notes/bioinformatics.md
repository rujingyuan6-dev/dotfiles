# 🧬 生信分析底层逻辑 —— 以你的项目为例

> 基于你本地项目: 16Bifido_ANI, 16s_diversity, 32Bifido, Kraken2, bowtie2
> 最后更新: 2026-06-23

---

## 目录

1. [你的研究在做什么](#1-你的研究在做什么)
2. [16S rRNA 测序 —— 鉴定细菌的"身份证"](#2-16s-rrna-测序--鉴定细菌的身份证)
3. [Nanopore 长读长数据处理流程](#3-nanopore-长读长数据处理流程)
4. [ANI 分析 —— 基因组层面的物种界定](#4-ani-分析--基因组层面的物种界定)
5. [系统发育树怎么看](#5-系统发育树怎么看)
6. [Kraken2 —— k-mer 快速物种分类](#6-kraken2--k-mer-快速物种分类)
7. [Bowtie2 —— 短读长比对与宿主去除](#7-bowtie2--短读长比对与宿主去除)
8. [SAM/BAM 文件格式](#8-sambam-文件格式)
9. [Slurm/PBS 任务数组](#9-slurmpbs-任务数组)
10. [你的项目全景图](#10-你的项目全景图)
11. [核心概念速查表](#11-核心概念速查表)

---

## 1. 你的研究在做什么

你研究的是 **双歧杆菌（Bifidobacterium）** —— 人类肠道中最重要的益生菌之一。

**核心问题：** 这些样本里有哪些双歧杆菌物种？它们之间的亲缘关系如何？

围绕这个问题，你的项目构成了一个完整的分析链条：

```
样本采集（小鼠肠道内容物）
    ↓
DNA 提取 → 16S PCR 扩增 → Nanopore 测序
    ↓
原始数据拆解（demultiplexing）
    ↓
质量过滤 → 聚类 → 生成一致性序列（consensus）
    ↓
BLAST 物种注释 → 就知道"有哪些菌"
    ↓
（同时）Kraken2 快速分类 → 交叉验证
    ↓
（同时）ANI 分析 → 搞清楚物种间的进化关系
    ↓
（同时）Bowtie2 去除宿主 DNA → 做 metagenomics
```

---

## 2. 16S rRNA 测序 —— 鉴定细菌的"身份证"

### 2.1 生物底层原理

所有细菌的核糖体上都有一个 **16S rRNA 基因**（大约 1540 个碱基对）。

这个基因之所以被选为"身份证"，是因为它同时具备两个特性：

```
16S rRNA 基因结构:
┌──────┬──────────────┬─────────┬──────────────┐
│ 保守区│   可变区     │ 保守区  │   可变区      │
└──────┴──────────────┴─────────┴──────────────┘
   ↑           ↑          ↑          ↑
  所有细菌    物种之间    所有细菌   物种之间
  都一样      不一样      都一样     不一样
```

- **保守区**：所有细菌都几乎一样 → 可以用"通用引物"一次性扩增所有细菌的 16S 基因
- **可变区**：不同物种序列不同 → 可以用来区分和鉴定物种

### 2.2 为什么用 16S 而不是其他基因？

| 方法 | 范围 | 通量 | 成本 | 信息量 |
|---|---|---|---|---|
| **16S 测序** | 细菌/古菌 | 高（一批几百样本） | 低 | 知道"有什么菌" |
| **全基因组测序** | 所有生物 | 低 | 高 | 知道"基因组长什么样" |
| **宏基因组** | 所有生物 | 中 | 中 | 知道"有什么基因" |

**选择 16S 的原因：** 如果你的目标只是知道"这个样本里有哪些双歧杆菌物种"，16S 是性价比最高的方法。

### 2.3 16S 分析的完整流程

```
粪便/肠道内容物样本
    ↓ ① 提取总 DNA（所有细菌的 DNA 混在一起）
PCR 扩增 16S 基因（只扩增 16S 片段，不扩增其他 DNA）
    ↓ ②
测序仪读取 16S 序列（你用的 Nanopore）
    ↓ ③
原始 reads → 质量过滤 → 拆分到每个样本（demultiplex）
    ↓ ④
聚类（OTU/ASV）→ 相似序列归为同一"类群"
    ↓ ⑤
与已知数据库比对 → 确定物种
    ↓
结果：样本 A 含 30% B.adolescentis, 20% B.longum, ...
```

---

## 3. Nanopore 长读长数据处理流程

（对应你的 `20260513_16s_diversity/pipeline_core.py`，共 11 步）

### 3.1 原始数据格式

```
FASTQ 格式（每 4 行一组）:
行1: @SEQ_ID   ← read 名称
行2: ATCGATCGATCGATCG...  ← 碱基序列
行3: +         ← 分隔符
行4: FFFFFF...FFFFFF      ← 质量值（每个碱基的质量分数）
```

质量值 Q 的公式：`Q = -10 × log₁₀(P)`，其中 P 是测序错误率。

| Q 值 | 错误率 | 准确率 |
|---|---|---|
| Q10 | 10% | 90% |
| Q20 | 1% | 99% |
| Q30 | 0.1% | 99.9% |
| Q40 | 0.01% | 99.99% |

你的脚本做了 **Q20 平均质量过滤**：一条 read 所有碱基的平均 Q 值低于 20 就扔掉。

### 3.2 四重条形码拆解（Demultiplexing）

**为什么需要 demultiplex？**

> 测序一个样本成本差不多，所以你同时测了 N 个样本 → 拿到混合数据 → 每个 read 开头有不同的"条形码"（barcode）标记它来自哪个样本 → 按 barcode 拆开。

你对每条 read 识别了 **4 个 barcode** 来拆解：

```
正向 read 结构:
ADAPTER1 - bc3 - ADAPTER2 - bc1 - PRIMER_F - [16S序列] - rc(PRIMER_R) - rc(bc2) - rc(ADAPTER3) - rc(bc4) - rc(ADAPTER4)

你的脚本做的事:
1. 找到 bc1 序列（8bp）→ 确定样本身份
2. 找到 bc3 序列（8bp）→ 双重确认
3. 找到 bc2 和 bc4 → 再确认
4. 剪掉 adapter 和 barcode，只保留 16S 片段
5. 存到对应样本的文件
```

用 4 个 barcode 而不是 1 个，是因为 **冗余校验** -> 即使某个 barcode 有测序错误，其他三个也能帮你正确识别样本归属。

### 3.3 相似性支持过滤

```
同一个样本里，多条 reads 都来自同一个 16S 基因模板：
  read1: AGCTAGCTAGCTAGCTAGCTAGCT
  read2: AGCTAGCTAGCTAGCTAGCTAGCT  ← 跟大部分一致
  read3: AGCTAGCTAGCTGGCTAGCTAGCT  ← 不一样！可能是错误
  read4: AGCTAGCTAGCTAGCTAGCTAGCT
  read5: AGCTAGCTAGCTAGCTAGCTAGCT

→ 少数服从多数，剔除 read3
```

### 3.4 一致性序列（Consensus calling）

这是纠正 Nanopore 高错误率的关键步骤：

```
同一模板的多个副本：
read1:  AGCTAGCTAGCTAGCTAGC
read2:  AGCTAGCTAGCTAGCTAGC
read3:  AGCTAGCTAGCTGGCTAGC    ← 错误！（G 应该是 A）
read4:  AGCTAGCTAGCTAGCTAGC
read5:  AGCTAGCTAGCTAGCTAGC

每个位置投票：
A A A A A → A（一致）
G G G G G → G（一致）
C C C C C → C（一致）
T T G T T → T（3:1 胜出，纠正了 read3 的错误）

最终 consensus:  AGCTAGCTAGCTAGCTAGC
```

**效果：** 单条 Nanopore read 准确率 ~90%，但 100 条 reads 投票出来的 consensus 准确率 > 99.9%。

### 3.5 BLAST 物种注释

```
consensus 16S 序列
    ↓
与已知数据库比对（你的 ssu_all.fna，113 万条已知 16S 序列）
    ↓
找到最匹配的
    ↓
匹配度 ≥ 97% → 同一物种
匹配度 ≥ 95% → 同一属
匹配度 ≥ 90% → 同一科
```

---

## 4. ANI 分析 —— 基因组层面的物种界定

（对应你的 `16Bifido_ANI_20260509` 项目）

### 4.1 什么是 ANI？

**Average Nucleotide Identity（平均核苷酸一致性）** = 两个基因组之间平均每个基因的序列相似度。

### 4.2 为什么 ANI 比 16S 更准？

| | 16S | ANI |
|---|---|---|
| 比较范围 | 1 个基因（~1500 bp） | 整个基因组（数百万 bp） |
| 分辨率 | 低 | 高 |
| 能区分近缘物种？ | 有时不能 | 能 |
| 成本 | 低 | 高（需要基因组数据） |
| 国际标准 | 辅助手段 | **金标准** |

**比喻：**
- 16S = 看一个人的脸（大致判断是谁）
- ANI = 比对指纹（精确确认身份）

### 4.3 ANI 的操作流程

你做的事情：

```
1. 从 NCBI 下载 16 个 Bifidobacterium 物种的基因组（FASTA 文件）
2. 两两之间用 fastANI 计算 ANI
3. 得到 25600 条比对结果（16 × 16 × 100 个随机片段）
4. 用 ANI 矩阵构建系统发育树
```

fastANI 结果文件解读（`fastANI_results.txt`）：

```
基因组A               基因组B              ANI%    匹配片段  总片段
GCF_000007525.1 ...  GCF_000196575.1 ...  98.7349  675       753
                                              ↑       ↑        ↑
                                          ANI > 95%  匹配了 675/753 个片段
                                          → 同一物种
```

### 4.4 物种界定的 95% 规则

```
ANI 95% 是一个经过几十年验证的"魔法数字"：

两个基因组 ANI > 95% → 同一个物种 ✓
两个基因组 ANI < 95% → 不同物种 ✓

这个阈值基于大量实验验证：传统上通过 DNA 杂交实验
（DNA-DNA hybridization, DDH）定义的物种阈值，换算
过来正好对应 ANI 95%。
```

---

## 5. 系统发育树怎么看

（对应你的 `16S_tree.nwk` / `ANI_tree.nwk`）

### 5.1 树的格式

Newick 格式是进化树的"文本表示"：

```
原始文本:
(B_adolescentis:0.02, (B_longum:0.05, B_breve:0.06):0.03);

对应的树：
┌─ B_adolescentis (长度 0.02)
┤
│    ┌─ B_longum (长度 0.05)
└────┤
     └─ B_breve (长度 0.06)
```

**关键概念：**
- **分支长度** = 进化距离（差异程度），越长差异越大
- **节点** = 共同祖先
- **越靠近的物种**，亲缘关系越近

### 5.2 你为什么要建两棵树？

```
16S 树                   ANI 树
（基于 16S 基因）         （基于全基因组）
    ↓                       ↓
分辨率低                 分辨率高
能看到大致关系           能看到精细关系

比较两棵树 →
如果某个菌在 16S 树上的位置跟 ANI 树上不一样 →
  可能发生了"水平基因转移"或"重组" → 值得深挖！
```

---

## 6. Kraken2 —— k-mer 快速物种分类

（对应你的 `Kraken2/` 目录）

### 6.1 k-mer 是什么？

```
序列 ATCGATCGATCG
切成 k=5 的片段（k-mer）：
ATCGA
TCGAT
CGATC
GATCG
ATCGA
  ...
```

k-mer 就是把长序列切成固定长度的小片段。每个 k-mer 就是一个"特征标记"。

### 6.2 Kraken2 的工作原理

```
一条测序 read:
AGCTAGCTAGCTAGCTAGCT

1. 切成 k=31 的 k-mers（滑动窗口）
   AGCTAGCTAGCTAGCTAGCTA
   GCTAGCTAGCTAGCTAGCTAG
   CTAGCTAGCTAGCTAGCTAGC
   ...

2. 每个 k-mer 在数据库里搜索
   AGCTAG... → 匹配到 Bifidobacterium adolescentis 的基因组
   GCTAGC... → 匹配到 Bifidobacterium adolescentis 的基因组
   CTAGCT... → 匹配到 Bifidobacterium adolescentis 的基因组
   TAGC...   → （没有匹配）
   AGCTA...  → 匹配到 Escherichia coli （污染？）
   ...

3. 统计各物种的 k-mer 匹配数
   B. adolescentis:    90 个 k-mer 匹配（90%）
   E. coli:            10 个 k-mer 匹配（10%）
   
4. 结论：这条 read 分类为 Bifidobacterium adolescentis
```

**Kraken2 速度极快的原因：** 它是精确的 k-mer 查找（哈希表），不是序列比对（BLAST 那种），后者计算量大得多。

### 6.3 你的数据库

```
你下载的 k2_standard 数据库包含：
  ─ 所有细菌（bacteria）的标准 k-mer 指纹
  ─ 所有古菌（archaea）
  ─ 所有病毒（viral）
  ─ 人类基因组（human，用来过滤宿主污染）
  ─ 质粒（plasmid）
  ─ 载体序列（UniVec）

大小约 6.1 GB，存储在 ~/database/kraken2_gtdb/
```

---

## 7. Bowtie2 —— 短读长比对与宿主去除

（对应你的 `bowtie2/` 目录）

### 7.1 比对（Mapping）的核心思想

```
参考基因组: chr1: ATCGATCGATCGATCGATCGATCG
                              ↓
测序 read:          GATCGATCGATCG
                              ↓
找到 read 在基因组上的最佳匹配位置
```

### 7.2 索引的作用

```
没有索引时：
  要把一条 read 跟 30 亿 bp 的人类基因组逐位比较 →
  计算量巨大，一条 read 要几十秒

有索引时（Bowtie2 的方法）：
  1. 把基因组切碎建哈希表（就像字典的索引目录）
  2. 用 read 的关键片段查索引 → 立刻定位候选区域
  3. 只在候选区域做精确比对 → 一条 read 几毫秒

建索引: bowtie2-build genome.fa genome.bt2
  → 产生 .bt2 文件（你的 GRCm39.bt2.*.bt2）
```

### 7.3 你在做什么

```
你的样本来自小鼠肠道
    ↓
测序得到的数据里大部分是小鼠 DNA + 少量微生物 DNA
    ↓
你的策略：
  1. bowtie2 把 reads 比对到小鼠基因组（GRCm39）
  2. 比对上的 → 宿主 DNA，扔掉
  3. 比对不上的（unmapped reads）→ 微生物 DNA，保留
  4. 用剩余的 reads 做后续分析（Kraken2 / 组装）
```

---

## 8. SAM/BAM 文件格式

### 8.1 SAM 文件长什么样

```
SAM 每行一条 read 的比对结果：

read1  →  匹配到 chr1 位置 12345，正向，序列 ATCG..., 质量值...
read2  →  匹配到 chrX 位置 45678，反向，序列 GCTA..., 质量值...  
read3  →  未匹配（*），序列 AGCT..., 质量值...

列 1: read 名称
列 2: flag（比对方向、是否唯一等）
列 3: 染色体名称
列 4: 在染色体上的起始位置
列 6: CIGAR 字符串（描述比对细节）
列 10: 序列
列 11: 质量值
```

### 8.2 CIGAR 字符串

```
CIGAR 描述 read 是如何比对到参考基因组的：

read:    AGCT-AGCTAGCT--AGCTAG
ref:     AGCT-AGCTAGCTA-AGCTAG
match:   |||| ||||||||  |||||
         AGCT AGCTAGCT  AGCT
         
CIGAR:   4M1D8M1D1I5M

M = match（匹配或错配）
I = insertion（插入 ---- read 多了一个碱基）
D = deletion（删除 ---- ref 多了一个碱基）
```

### 8.3 BAM vs SAM

```
SAM = 文本格式（人类可读，占用空间大）
BAM = 二进制格式（计算机高效，压缩后节约 5-10 倍空间）

流程: SAM（原始）→ samtools sort → BAM（排序后的二进制）
你的脚本里:
  bowtie2 输出 SAM → pipe 到 samtools sort → 直接输出 BAM
```

---

## 9. Slurm/PBS 任务数组

### 9.1 为什么需要任务数组

```
你有 50 个样本需要 bowtie2 比对：
  
  方案 A（串行）:
  sample1 → 2 小时 → sample2 → 2 小时 → ... → 50 × 2 = 100 小时
  
  方案 B（任务数组）:
  ┌─ sample1 (2h)
  ├─ sample2 (2h)
  ├─ sample3 (2h)    ← 并行，总耗时还是 2 小时
  ├─ ...
  └─ sample50 (2h)
  
  不是 100 小时，而是 2 小时！
```

### 9.2 你的脚本是怎么做的

```
你的 samples.tsv 文件（由 make_samples_tsv.sh 生成）:
  sample1  /path/to/R1.fq.gz  /path/to/R2.fq.gz
  sample2  /path/to/R1.fq.gz  /path/to/R2.fq.gz
  sample3  /path/to/R1.fq.gz  /path/to/R2.fq.gz
  ...

提交:
  sbatch --array=1-50 03.bowtie2_map_array.sbatch

每个任务（$SLURM_ARRAY_TASK_ID）:
  第 1 个任务: sed -n "1p" samples.tsv → sample1
  第 2 个任务: sed -n "2p" samples.tsv → sample2
  ...
  
你的脚本的关键行:
  IFS=$'\t' read -r sample r1 r2 < <(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES_TSV")
  # 读取第 SLURM_ARRAY_TASK_ID 行的样本名、R1路径、R2路径
```

### 9.3 PBS vs Slurm

```
PBS 系统（你的 Kraken2 脚本）:
  #PBS -l nodes=1:ppn=32
  #PBS -l mem=200gb
  qsub 01.build_kraken2_db.pbs

Slurm 系统（你的 bowtie2 脚本）:
  #SBATCH -N 1
  #SBATCH -c 12
  #SBATCH --mem=64G
  sbatch 03.bowtie2_map_array.sbatch
```

你的服务器上两种作业管理系统都有，基本概念一样。

---

## 10. 你的项目全景图

```
┌─────────────────────────────────────────────────────────────────┐
│                        你的课题                                  │
│              小鼠肠道双歧杆菌研究                                │
└─────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼──────────────────────────────┐
        │                           │                              │
        ▼                           ▼                              ▼
┌──────────────────┐   ┌──────────────────────┐   ┌───────────────────┐
│ 实验验证         │   │ 测序数据处理         │   │ 计算分析          │
│                  │   │                      │   │                   │
│ MIC_test/        │   │ 32Bifido_analysis/   │   │ 16Bifido_ANI/     │
│  MIC 药敏实验    │   │  demultiplex + merge │   │  fastANI + 进化树 │
│                  │   │                      │   │                   │
│ HRexperiment/    │   │ 20260513_16s_.../    │   │ Kraken2/          │
│  细胞实验        │   │  完整 pipeline       │   │  k-mer 物种分类   │
│                  │   │  11 个步骤           │   │                   │
│                  │   │                      │   │ bowtie2/          │
│                  │   │                      │   │  宿主去除流程     │
└──────────────────┘   └──────────────────────┘   └───────────────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │ 参考数据库      │
                        │ database/       │
                        │  ├── kraken2    │
                        │  └── ssu_all    │
                        │ reference/      │
                        │  └── 各种 db    │
                        └─────────────────┘
```

---

## 11. 核心概念速查表

| 概念 | 一句话 | 你的哪个项目用到 |
|---|---|---|
| **16S rRNA** | 细菌的"身份证"基因，用来鉴定物种 | 16s_diversity, 32Bifido |
| **FASTQ** | 原始测序数据格式（序列+质量值） | 所有项目 |
| **Demultiplex** | 按 barcode 拆分混合样本 | 32Bifido, 16s_diversity |
| **Consensus** | 多条 reads 投票纠错 | 16s_diversity Step 8 |
| **OTU/ASV** | 相似的 16S 序列归为一组 | 16s_diversity |
| **ANI** | 全基因组相似度，物种界定的金标准 | 16Bifido_ANI |
| **k-mer** | 把序列切成固定长度小片段 | Kraken2 |
| **BLAST** | 在数据库中搜索相似序列 | 16s_diversity Step 10 |
| **SAM/BAM** | 比对结果的文件格式 | bowtie2 |
| **Index** | 基因组的"目录"，加速比对 | bowtie2, Kraken2 |
| **Task array** | 并行处理多个样本 | bowtie2, 16s_diversity |
| **PBS/Slurm** | 服务器作业管理系统 | Kraken2 (PBS), bowtie2 (Slurm) |

---

## 附录：继续学习建议

如果你想把基础打扎实，建议按这个顺序理解：

```
1. FASTQ 格式 ↔ 原始数据长什么样
   ↓
2. 比对（alignment） ↔ 最核心的操作
   ↓
3. k-mer 概念 ↔ 从比对到分类到组装
   ↓
4. 统计基础 ↔ P 值、多重检验校正、FDR
   ↓
5. Linux 基础 ↔ 文件操作、权限、管道
   ↓
6. Python/Shell 脚本 ↔ 自动化分析
```

有问题随时可以问 —— 你的代码就摆在这台机器上，我可以结合具体代码给你讲。
