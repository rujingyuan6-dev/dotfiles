# 🧰 工具速查手册

## 🔐 SSH 远程连接

```bash
ssh server                          # 免密登录服务器（最常用）
ssh rujingyuan@192.168.53.18        # 完整写法，记不住 IP 就用上面的
```

> 配置在 `~/.ssh/config`，由 git 管理

---

## 📂 Git 版本控制

```bash
lazygit                     # 🎯 推荐！图形界面，不用记命令
git status                  # 查看哪些文件改了
git add <文件>               # 暂存文件
git commit -m "说明"         # 提交
git push                    # 推送到 GitHub
git pull                    # 从 GitHub 拉取最新
git log --oneline           # 看提交历史
```

> dotfiles 仓库在 `~/`，已关联 GitHub

---

## 🐚 zsh 快捷键

| 快捷键 | 功能 |
|---|---|
| `Ctrl+R` | 模糊搜索历史命令（fzf，超好用） |
| `Ctrl+T` | 模糊搜索文件名（fzf） |
| `Tab` 按一下 | 自动补全 |
| `Tab` 按两下 | 列出所有匹配项 |
| `Ctrl+D` | 退出终端 |
| `↑↓` | 上下翻历史（带 fuzzy 补全提示） |

---

## 🔍 文件搜索

```bash
fd <名字>          # 搜索文件/目录名（秒出结果）
fd -e py           # 只搜索 .py 文件
fd -I <名字>       # 忽略 .gitignore 限制

rg <关键词>         # 搜索文件内容（秒出结果）
rg -i <关键词>      # 忽略大小写
rg -l <关键词>      # 只显示文件名
rg -C 3 <关键词>    # 显示上下文（上下各3行）
rg "函数名" --type py   # 只搜 Python 文件
```

---

## 📖 查看文件

```bash
bat <文件>          # 带语法高亮和行号查看文件（最常用）
cat <文件>          # 纯文本输出（已有 alias）

tldr <命令>         # 🎯 命令速查，比 man 手册实用一百倍
tldr tar           # 例：查看 tar 的常用用法
tldr ffmpeg        # 例：视频处理
tldr rg            # 例：查看 rg 的用法
tldr --list        # 列出所有可查的命令
```

---

## ✏️ Neovim 编辑器

```bash
vi <文件>           # 打开文件编辑（alias 到 nvim）
```

### 常用快捷键

```
:q     退出
:q!    强制退出（不保存）
:w     保存
:wq    保存退出
dd     删除当前行
yy     复制当前行
p      粘贴
u      撤销
Ctrl+r 重做
gg     跳到文件开头
G      跳到文件末尾
/关键词  搜索（n 下一个，N 上一个）
:set nu  显示行号
```

---

## 📁 快速目录跳转

```bash
z <关键词>          # 跳到常用目录
z down             # 跳到 ~/Downloads（如果有这个目录历史）
z dot              # 跳到 dotfiles 相关目录
```

> 用的是 oh-my-zsh 的 `z` 插件，自动根据你的访问频率跳转

---

## 📦 已安装的工具一览

| 工具 | 用途 | 安装位置 |
|---|---|---|
| `zsh` | 增强版 shell | `~/.local/bin/zsh` |
| `nvim` | 终端编辑器 | `~/.local/bin/nvim` |
| `lazygit` | Git 图形界面 | `~/.local/bin/lazygit` |
| `bat` | 文件查看(高亮) | `~/.local/bin/bat` |
| `rg` (ripgrep) | 搜索文件内容 | `~/.local/bin/rg` |
| `fd` | 搜索文件名 | `~/.local/bin/fd` |
| `fzf` | 模糊搜索 | `~/.fzf/bin/fzf` |
| `tldr` | 命令速查 | pip 安装 |
| `starship` | 提示符美化 | `~/.local/bin/starship` |

---

> 💡 记不住？终端里输入 `cheatsheet` 或 `cs` 或 `helpme` 就能看到精简版

---

## 🚀 换新电脑时一键恢复

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/rujingyuan6-dev/dotfiles/master/bootstrap.sh)
```

这条命令会：
1. 克隆 dotfiles 配置到 `~`（冲突文件自动备份）
2. 安装全部工具到 `~/.local/bin`
3. 安装 Oh My Zsh、Nerd Font、nvim 插件
4. 设置 starship 主题
