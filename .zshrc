# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z extract zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bat 配置
alias cat="bat -pp"          # 纯文本（无行号）的 bat
alias catt="bat -A"          # 显示不可见字符
alias catp="bat -p"          # 带行号的纯文本
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="Dracula"   # 主题（可换：catppuccin, gruvbox, Nord 等）

# pip 用户包路径
export PATH="$(python3 -c "import site; print(site.USER_BASE)")/bin:$PATH"

# Neovim
alias vi="nvim"
alias vim="nvim"
export EDITOR="nvim"

# Starship 提示符
eval "$(starship init zsh)"

# ============================================
# 🧰 工具速查 — 输入 cheatsheet 即可查看
# ============================================
cheatsheet() {
  cat <<'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧰  工具速查手册
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐  SSH 远程连接
   ssh server                 # 免密登录服务器

📂  Git 版本控制
   lazygit                    # Git 图形界面（推荐！）
   git status                 # 查看更改
   ga . && gcmsg "x" && gp    # 完整三连（alias）

🪟  byobu / tmux 终端复用器
   byobu                      # 🎯 推荐！启动（带状态栏/快捷键提示）
   tmux                       # 或者直接用 tmux
   F9          byobu 配置菜单
   Ctrl+A  ?  查看全部快捷键
   Ctrl+A  |  左右分屏
   Ctrl+A  -  上下分屏
   Ctrl+A  ←↑↓→  切换窗格
   Ctrl+A  c  新标签页
   Ctrl+A  d  断开（程序继续在后台跑）
   byobu -r   重新连回去
   F2         新建窗口（byobu 快捷键）
   F3/F4      上一个/下一个窗口

🐚  Shell 快捷键
   Ctrl+R    模糊搜索历史命令
   Ctrl+T    模糊搜索文件名
   Tab 补全  按一下补全，两下列表

🔍  文件搜索
   fd <名字>           # 搜索文件（比 find 快）
   rg <关键词>          # 搜索文件内容（比 grep 快）

📖  查看文件 & 系统监控
   bat <文件>           # 带语法高亮的 cat
   htop                 # 系统进程监控（像任务管理器）
   tldr <命令>          # 命令速查（精简版 man）
      例: tldr tar  tldr ffmpeg

✏️  Neovim 编辑器
   vi <文件>            # 打开编辑（已 alias）

📁  目录跳转
   z <关键词>           # 跳到常用目录
      例: z down  → 跳到 ~/Downloads

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡  记不住就输入:   cheatsheet   或   cs
    想查某命令用法:  tldr <命令>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# 加个更短的名字
alias cs="cheatsheet"
alias helpme="cheatsheet"
