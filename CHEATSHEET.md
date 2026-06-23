# 🧰 工具速查手册

> 记不住？终端里输入 `cheatsheet`（或 `cs` / `helpme`）查看精简版

---

## 📖 怎么用这套环境？

### 工作流：从打开终端开始

```bash
# 1. 打开终端 → 自动进入 zsh + starship 主题
# 2. 想去哪个目录？
z project          # 智能跳转（zoxide，自动学习）
zi                 # 交互式选目录

# 3. 要找什么文件？
fd "关键词"         # 搜文件名（比 find 快几十倍）
rg "关键词"         # 搜文件内容（比 grep 快几十倍）

# 4. 想编辑文件？
vi some-file.py    # nvim 编辑器

# 5. Git 操作？
lazygit            # 图形界面，不用记命令

# 6. 查命令怎么用？
tldr ffmpeg        # 速查（比 man 精简）
```

---

## 🚪 SSH 远程连接

```bash
ssh server                          # 免密登录服务器
scp file.txt server:~/              # 复制文件到服务器
```

> 配置在 `~/.ssh/config`，由 git 管理。密码？不存在。

---

## 📂 Git 版本控制

| 场景 | 命令 |
|---|---|
| **图形界面操作（推荐）** | `lazygit` |
| 看改了啥 | `git status` |
| 三连发 | `git add . && git commit -m "x" && git push` |
| 拉取最新 | `git pull` |

---

## 🪟 终端分屏（byobu / tmux）

> 连了服务器要同时做多件事？分屏啊！

```bash
byobu           # 🎯 启动（底部有状态栏和快捷键提示）
```

| 按键 | 功能 |
|---|---|
| `F2` | 新建标签页 |
| `F3` / `F4` | 切换标签页 |
| `Ctrl+A` `\|` | 左右分屏 |
| `Ctrl+A` `-` | 上下分屏 |
| `Ctrl+A` `←↑↓→` | 切换窗格 |
| `Ctrl+A` `d` | 断开（程序继续跑） |
| `byobu -r` | 重新连回来 |

---

## 🔍 文件搜索

### 找文件名（fd）

```bash
fd .py                   # 所有 Python 文件
fd -e md                 # 所有 markdown 文件
fd report                # 搜名字里有 report 的文件/目录
fd -I large              # 忽略 .gitignore 限制
```

### 找文件内容（rg，原 ripgrep）

```bash
rg "def main"            # 搜索代码
rg -i "error"            # 忽略大小写
rg -C 3 "TODO"           # 上下各 3 行显示上下文
rg "class.*Model" --type py  # 只搜 py 文件
```

> **fd 和 rg 是日常最高频的工具** —— 找东西不必再用鼠标点点点。

---

## 📖 查看文件 & 系统监控

### 文件查看

```bash
bat config.json          # 带语法高亮和行号（比 cat 好用太多）
cat file.txt             # 纯文本输出（已 alias 到 bat -pp）
```

### 命令速查

```bash
tldr tar                 # tar 的常用用法，不看废话
tldr ffmpeg              # 视频处理
tldr rg fd bat           # 搜这些工具的用法
```

### 系统监控

```bash
btop                     # 🎯 酷炫系统监控（CPU/内存/网络实时图表）
htop                     # 另一个（更轻量）
```

---

## 📁 智能目录跳转

```bash
cd ~/Desktop/project/python/src  # 先去一次，zoxide 就学会了

z desktop                # 下次直接跳 → ~/Desktop
z src                    # → project/python/src  
z dot                    # → dotfiles 目录
zi                       # 交互式选择（模糊搜索）
```

> **zoxide 是你用越久越聪明的工具。** 不用刻意学，多用 `z` 自然就习惯。

---

## ✏️ Neovim 编辑器

```bash
vi file.py               # 打开编辑
```

| 快捷键 | 功能 |
|---|---|
| `:q` / `:wq` | 退出 / 保存退出 |
| `dd` / `yy` / `p` | 删行 / 复制行 / 粘贴 |
| `u` / `Ctrl+r` | 撤销 / 重做 |
| `gg` / `G` | 文件头 / 文件尾 |
| `/关键词` + `n` / `N` | 搜索 / 下一个 / 上一个 |

---

## 🐚 终端快捷键

| 快捷键 | 功能 |
|---|---|
| `Ctrl+R` | **模糊搜索历史命令**（最实用！） |
| `Ctrl+T` | **模糊搜索文件名** |
| `Tab` 按一下 | 自动补全 |
| `Tab` 按两下 | 列出所有可能项 |

---

## 🐳 容器（Podman / Docker）

> 没有 root 权限，所以用 Podman 替代 Docker。命令完全兼容。

```bash
docker ps                    # 查看运行中的容器（实际是 podman）
docker images                # 列出镜像
docker pull nginx            # 拉取镜像
docker run -it ubuntu bash   # 运行容器
docker run --network=host -it ubuntu bash   # 如果网络有问题加这个
docker stop <容器ID>
docker rm <容器ID>
```

---

## 🐍 Python 环境（conda / mamba）

```bash
# mamba 比 conda 快很多，日常用它
mamba create -n project python=3.12   # 新建环境
mamba activate project                # 激活环境
mamba install numpy pandas            # 装包
mamba deactivate                      # 退出

# 其他
conda env list                        # 列出所有环境
```

---

## 🟢 Node.js 环境（nvm）

```bash
nvm install --lts                     # 安装最新 LTS
nvm use 20                            # 切换版本
nvm ls                                # 列出已装版本
node -v && npm -v                     # 查看当前版本
```

---

## 📦 已安装工具总表

| 工具 | 用来干什么 | 怎么启动 |
|---|---|---|
| **zsh** | 增强版 shell（自动补全、主题） | 开终端即是 |
| **starship** | 命令提示符（显示 git 分支、时间等） | 自动 |
| **zoxide** | 智能跳转目录 | `z <关键词>` |
| **fzf** | 模糊搜索（Ctrl+R 搜历史等） | `Ctrl+R` / `Ctrl+T` |
| **bat** | 文件查看（语法高亮） | `bat <文件>` |
| **fd** | 搜索文件名 | `fd <关键词>` |
| **rg** | 搜索文件内容 | `rg <关键词>` |
| **lazygit** | Git 图形界面 | `lazygit` |
| **nvim** | 终端编辑器 | `vi <文件>` |
| **yazi** | 文件管理器 (Rust) | `yazi` |
| **joshuto** | 文件管理器 (Rust) | `joshuto` |
| **ranger** | 文件管理器 (Python) | `ranger` |
| **byobu** | 终端分屏 | `byobu` |
| **btop** | 系统监控（酷炫） | `btop` |
| **htop** | 系统监控（轻量） | `htop` |
| **tldr** | 命令速查 | `tldr <命令>` |
| **conda / mamba** | Python 环境管理 | `mamba create / install` |
| **nvm** | Node.js 版本管理 | `nvm install / use` |
| **podman** | 容器引擎（代替 Docker） | `docker ps / run / pull` |
| **oh-my-zsh** | zsh 插件框架 | 自动 |

---

## 🔬 生信分析工作流：本地编辑 + 服务器跑计算

```bash
# ── 第1步：本地写脚本 ──
cd ~/Desktop && mkdir -p my_project && cd my_project
vi run_analysis.sh          # 或 micro run_analysis.sh

# ── 第2步：传到服务器 ──
scp run_analysis.sh server:~/my_project/
# 如果有数据: scp sample.fastq server:~/my_project/
# 一键推整个目录: scp -r . server:~/my_project/

# ── 第3步：SSH 上服务器跑分析 ──
ssh server
cd ~/my_project
byobu                    # 防断开（关键！）
conda activate bio
bash run_analysis.sh     # 跑吧，几小时那种
# Ctrl+A → d  断开，去吃饭 💤
# 关终端，程序继续跑

# ── 第4步：回来检查 ──
ssh server
byobu -r                 # 重新连上

# ── 第5步：结果拉回本地 ──
scp server:~/my_project/results.txt ~/Desktop/my_project/
bat results.txt
```

> 记住这条链：**本地写 → scp → 服务器 byobu 跑 → 本地看结果**

---

## 🚀 换新电脑时

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/rujingyuan6-dev/dotfiles/master/bootstrap.sh)
```

一条命令恢复全部配置和工具。

---

## 💡 记不住怎么办？

```
cheatsheet    # 终端里随时看精简版
cs            # 同上（更短）
tldr <命令>   # 查任何命令怎么用
```

> **用得多自然就熟了** —— 头几天刻意用 `z`、`fd`、`rg`、`Ctrl+R`，三天后就会变成肌肉记忆。
