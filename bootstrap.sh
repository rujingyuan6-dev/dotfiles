#!/usr/bin/env bash
# ============================================
# 🚀 dotfiles 一键恢复脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/rujingyuan6-dev/dotfiles/master/bootstrap.sh | bash
# 或者: bash <(curl -fsSL ...)
# ============================================
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }

# ---------- 1. 检测系统 ----------
info "系统检测中..."
OS=""
if [[ "$(uname)" == "Darwin" ]]; then
  OS="macos"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS="$ID"
fi
echo "  系统: $OS"

# ---------- 2. 安装依赖工具 ----------
install_pkg() {
  local cmd="$1" pkg="$2"
  if command -v "$cmd" &>/dev/null; then
    ok "$cmd 已安装"
    return 0
  fi
  info "安装 $pkg..."

  if [[ "$OS" == "macos" ]]; then
    brew install "$pkg" 2>/dev/null
  elif [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    sudo apt-get install -y "$pkg" 2>/dev/null
  elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" ]]; then
    sudo yum install -y "$pkg" 2>/dev/null
  else
    warn "未知系统，跳过 $pkg 安装"
    return 1
  fi

  if command -v "$cmd" &>/dev/null; then
    ok "$pkg 安装成功"
  else
    warn "$pkg 安装可能失败，后续尝试二进制安装"
    return 1
  fi
}

install_binary() {
  local name="$1" url="$2"
  info "下载 $name..."
  curl -L -o "/tmp/$name" "$url" 2>/dev/null
  chmod +x "/tmp/$name"
  mkdir -p "$HOME/.local/bin"
  cp "/tmp/$name" "$HOME/.local/bin/"
  if command -v "$name" &>/dev/null || [[ -x "$HOME/.local/bin/$name" ]]; then
    ok "$name 安装成功"
  else
    warn "$name 安装失败"
  fi
}

# ---------- 3. 系统工具 ----------
info "\n=== 系统工具 ==="
install_pkg git git
install_pkg curl curl
install_pkg wget wget
install_pkg unzip unzip
install_pkg xclip xclip

# ---------- 4. zsh ----------
info "\n=== Shell ==="
if ! command -v zsh &>/dev/null; then
  install_pkg zsh zsh
  if command -v zsh &>/dev/null; then
    sudo chsh -s "$(which zsh)" "$USER" 2>/dev/null || warn "chsh 失败，手动运行: chsh -s $(which zsh)"
  fi
else
  ok "zsh 已安装 ($(zsh --version 2>&1 | head -1))"
fi

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "安装 Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null
  ok "Oh My Zsh 安装成功"
else
  ok "Oh My Zsh 已安装"
fi

# ---------- 5. 工具安装 ----------
info "\n=== 工具安装 ==="

# fzf
if [[ ! -f "$HOME/.fzf/bin/fzf" ]]; then
  [[ ! -d "$HOME/.fzf" ]] && git clone --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all 2>/dev/null
  ok "fzf 安装成功"
else
  ok "fzf 已安装"
fi

# bat
if ! command -v bat &>/dev/null; then
  info "安装 bat..."
  LATEST=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep "tag_name" | cut -d'"' -f4)
  VER=${LATEST#v}
  curl -L -o /tmp/bat.tar.gz "https://github.com/sharkdp/bat/releases/download/v${VER}/bat-v${VER}-x86_64-unknown-linux-gnu.tar.gz" 2>/dev/null
  cd /tmp && tar xzf bat.tar.gz && cp "bat-v${VER}-x86_64-unknown-linux-gnu/bat" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/bat" && ok "bat 安装成功" || warn "bat 安装失败"
else
  ok "bat 已安装"
fi

# rg (ripgrep)
if ! command -v rg &>/dev/null; then
  info "安装 ripgrep..."
  LATEST=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep "tag_name" | cut -d'"' -f4)
  VER=${LATEST#v}
  curl -L -o /tmp/rg.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${LATEST}/ripgrep-${VER}-x86_64-unknown-linux-musl.tar.gz" 2>/dev/null
  cd /tmp && tar xzf rg.tar.gz && cp "ripgrep-${VER}-x86_64-unknown-linux-musl/rg" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/rg" && ok "rg 安装成功" || warn "rg 安装失败"
else
  ok "rg 已安装"
fi

# fd
if ! command -v fd &>/dev/null; then
  info "安装 fd..."
  LATEST=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep "tag_name" | cut -d'"' -f4)
  VER=${LATEST#v}
  curl -L -o /tmp/fd.tar.gz "https://github.com/sharkdp/fd/releases/download/v${VER}/fd-v${VER}-x86_64-unknown-linux-gnu.tar.gz" 2>/dev/null
  cd /tmp && tar xzf fd.tar.gz && cp "fd-v${VER}-x86_64-unknown-linux-gnu/fd" "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/fd" && ok "fd 安装成功" || warn "fd 安装失败"
else
  ok "fd 已安装"
fi

# lazygit
if ! command -v lazygit &>/dev/null; then
  info "安装 lazygit..."
  LATEST=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep "tag_name" | cut -d'"' -f4)
  VER=${LATEST#v}
  curl -L -o /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/${LATEST}/lazygit_${VER}_linux_x86_64.tar.gz" 2>/dev/null
  cd /tmp && tar xzf lazygit.tar.gz && cp lazygit "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/lazygit" && ok "lazygit 安装成功" || warn "lazygit 安装失败"
else
  ok "lazygit 已安装"
fi

# nvim
if ! command -v nvim &>/dev/null; then
  info "安装 neovim..."
  LATEST=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep "tag_name" | cut -d'"' -f4)
  curl -L -o /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/${LATEST}/nvim-linux-x86_64.tar.gz" 2>/dev/null
  cd /tmp && tar xzf nvim.tar.gz && cp -r nvim-linux-x86_64/* "$HOME/.local/"
  ok "neovim 安装成功"
else
  ok "nvim 已安装"
fi

# starship
if ! command -v starship &>/dev/null; then
  info "安装 starship..."
  LATEST=$(curl -s https://api.github.com/repos/starship/starship/releases/latest | grep "tag_name" | cut -d'"' -f4)
  VER=${LATEST#v}
  curl -L -o /tmp/starship.tar.gz "https://github.com/starship/starship/releases/download/${LATEST}/starship-x86_64-unknown-linux-gnu.tar.gz" 2>/dev/null
  cd /tmp && tar xzf starship.tar.gz && cp starship "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/starship" && ok "starship 安装成功" || warn "starship 安装失败"
else
  ok "starship 已安装"
fi

# yazi
if ! command -v yazi &>/dev/null; then
  info "安装 yazi..."
  LATEST=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep "tag_name" | cut -d'"' -f4)
  curl -L -o /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${LATEST}/yazi-x86_64-unknown-linux-musl.zip" 2>/dev/null
  cd /tmp && unzip -o yazi.zip 2>/dev/null && cp yazi-x86_64-unknown-linux-musl/yazi "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/yazi" && ok "yazi 安装成功" || warn "yazi 安装失败"
else
  ok "yazi 已安装"
fi

# btop
if ! command -v btop &>/dev/null; then
  info "安装 btop..."
  LATEST=$(curl -s https://api.github.com/repos/aristocratos/btop/releases/latest | grep "tag_name" | cut -d'"' -f4)
  curl -L -o /tmp/btop.tar.gz "https://github.com/aristocratos/btop/releases/download/${LATEST}/btop-x86_64-unknown-linux-musl.tar.gz" 2>/dev/null
  cd /tmp && tar xzf btop.tar.gz && cp btop/bin/btop "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/btop" && ok "btop 安装成功" || warn "btop 安装失败"
else
  ok "btop 已安装"
fi

# tldr (pip)
if ! python3 -c "import tldr" 2>/dev/null; then
  info "安装 tldr (pip)..."
  pip3 install tldr --user 2>/dev/null
  ok "tldr 安装成功"
else
  ok "tldr 已安装"
fi

# ranger (pip)
if ! command -v ranger &>/dev/null; then
  info "安装 ranger (pip)..."
  pip3 install ranger-fm --user 2>/dev/null
  ok "ranger 安装成功"
else
  ok "ranger 已安装"
fi

# byobu (如果能 apt 安装)
if ! command -v byobu &>/dev/null; then
  install_pkg byobu byobu 2>/dev/null || warn "byobu 需要手动安装 (apt install byobu)"
fi

# ---------- 6. 安装字体 ----------
info "\n=== 字体 ==="
if [[ ! -f "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" ]]; then
  info "安装 Nerd Font..."
  mkdir -p "$HOME/.local/share/fonts"
  curl -L -o /tmp/Hack.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip" 2>/dev/null
  cd /tmp && unzip -o -q Hack.zip -d "$HOME/.local/share/fonts/" 2>/dev/null
  rm -f "$HOME/.local/share/fonts/"*.txt "$HOME/.local/share/fonts/"*.md 2>/dev/null
  fc-cache -fv "$HOME/.local/share/fonts/" 2>/dev/null
  ok "Nerd Font 安装成功"
else
  ok "Nerd Font 已安装"
fi

# ---------- 7. 安装 lazy.nvim 插件 ----------
info "\n=== Neovim 插件 ==="
if [[ -f "$HOME/.local/bin/nvim" ]]; then
  info "安装 nvim 插件（首次安装需下载，稍等片刻）..."
  "$HOME/.local/bin/nvim" --headless -c "lua require('lazy').sync()" -c "lua vim.wait(30000)" -c "qa" 2>/dev/null || true
  ok "nvim 插件安装完成"
fi

# ---------- 8. 完成 ----------
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  🎉  dotfiles 一键恢复完成！              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  重新登录终端或运行 ${CYAN}zsh${NC} 启用新环境"
echo -e "  输入 ${CYAN}cheatsheet${NC} 查看工具速查"
echo ""
echo "已安装工具:"
for cmd in zsh fzf bat rg fd lazygit nvim starship yazi btop tldr ranger byobu; do
  if command -v "$cmd" &>/dev/null; then
    echo -e "  ${GREEN}✔${NC} $cmd"
  else
    echo -e "  ${RED}✘${NC} $cmd (未安装)"
  fi
done
echo ""
echo "配置来源: https://github.com/rujingyuan6-dev/dotfiles"
