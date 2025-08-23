#!/bin/bash

# Modern Bash Configuration Installer
# 现代化Bash配置一键安装脚本
# Author: zxw
# Version: 1.0.0

set -e

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config/shell"
INSTALL_LOG="$HOME/bash_installer.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$INSTALL_LOG"
}

info() {
    log "${BLUE}[INFO]${NC} $1"
}

success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

error() {
    log "${RED}[ERROR]${NC} $1"
}

# 检查系统
check_system() {
    info "检查系统环境..."
    
    # 检查操作系统
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if command -v apt &> /dev/null; then
            PACKAGE_MANAGER="apt"
        elif command -v yum &> /dev/null; then
            PACKAGE_MANAGER="yum"
        elif command -v pacman &> /dev/null; then
            PACKAGE_MANAGER="pacman"
        else
            warning "未识别的包管理器，某些功能可能无法自动安装"
            PACKAGE_MANAGER="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if command -v brew &> /dev/null; then
            PACKAGE_MANAGER="brew"
        else
            warning "建议安装 Homebrew 以获得更好的体验"
            PACKAGE_MANAGER="unknown"
        fi
    else
        warning "未完全支持的操作系统: $OSTYPE"
        OS="unknown"
    fi
    
    info "操作系统: $OS, 包管理器: $PACKAGE_MANAGER"
}

# 创建备份
create_backup() {
    info "创建配置备份到 $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    
    # 备份现有配置文件
    for file in .bashrc .bash_aliases .bash_profile .profile .inputrc .dircolors; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$BACKUP_DIR/"
            info "备份 $file"
        fi
    done
    
    success "配置备份完成"
}

# 安装依赖工具
install_dependencies() {
    info "安装现代化Shell工具..."
    
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt update
            sudo apt install -y curl git fzf zoxide exa bat ripgrep fd-find hstr tmux vim
            ;;
        "yum")
            sudo yum install -y curl git fzf zoxide exa bat ripgrep fd-find hstr tmux vim
            ;;
        "pacman")
            sudo pacman -S --noconfirm curl git fzf zoxide exa bat ripgrep fd hstr tmux vim
            ;;
        "brew")
            brew install curl git fzf zoxide exa bat ripgrep fd hstr tmux vim
            ;;
        *)
            warning "无法自动安装依赖，请手动安装以下工具:"
            echo "- fzf (模糊搜索)"
            echo "- zoxide (智能目录跳转)"
            echo "- exa (现代化ls)"
            echo "- bat (现代化cat)"
            echo "- ripgrep (现代化grep)"
            echo "- fd (现代化find)"
            echo "- hstr (历史搜索增强)"
            ;;
    esac
    
    # 安装Starship (跨平台)
    if ! command -v starship &> /dev/null; then
        info "安装 Starship 终端提示符..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # 安装McFly
    if ! command -v mcfly &> /dev/null; then
        info "安装 McFly 智能历史管理..."
        curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
    fi
}

# 生成现代化配置
generate_config() {
    info "生成现代化Bash配置..."
    
    mkdir -p "$CONFIG_DIR"
    
    # 生成主配置文件
    cat > "$CONFIG_DIR/modern-config.sh" << 'EOF'
#!/bin/bash
# Modern Shell Configuration
# 现代化Shell配置

# ============ 基础配置 ============

# 启用别名扩展
shopt -s expand_aliases

# 历史配置优化
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:ignorespace:erasedups
shopt -s histappend
shopt -s checkwinsize

# ============ 颜色支持 ============

# 启用颜色支持
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# 设置locale
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# ============ 现代化工具配置 ============

# FZF - 模糊搜索配置
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --color=always --line-range :500 {}"'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'

# 加载FZF键绑定
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
elif [ -f /usr/share/fzf/key-bindings.bash ]; then
    source /usr/share/fzf/key-bindings.bash
elif [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi

# Zoxide - 智能目录跳转
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# McFly - 智能历史管理
if command -v mcfly &> /dev/null; then
    eval "$(mcfly init bash)"
fi

# Starship - 美化终端提示符
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# HSTR - 历史搜索增强
if command -v hstr &> /dev/null; then
    export HSTR_CONFIG=hicolor,prompt-bottom,blacklist
    bind '"\C-r": "\C-a hh \C-j"'
fi

# ============ 别名定义 ============

# 基础命令增强
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# 现代化ls命令
if command -v exa &> /dev/null; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -la --icons --group-directories-first --time-style=long-iso'
    alias la='exa -a --icons --group-directories-first'
    alias l='exa --icons --group-directories-first'
    alias lt='exa -la --icons --sort=modified'
    alias lh='exa -la --icons --group-directories-first'
    alias lta='exa --tree --level=2 --icons'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -alF --color=auto --group-directories-first --time-style=long-iso'
    alias la='ls -A --color=auto --group-directories-first'
    alias l='ls -CF --color=auto --group-directories-first'
    alias lt='ls -altr --color=auto'
    alias lh='ls -alh --color=auto --group-directories-first'
fi

# 现代化cat命令
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias bcat='bat'
fi

# 现代化grep命令
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# 现代化find命令
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# 目录导航增强
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Zoxide别名
if command -v zoxide &> /dev/null; then
    alias cd='z'
    alias cdi='zi'
fi

# 文件操作安全化
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Git 快捷别名
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# 系统信息增强
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps aux'
alias top='htop 2>/dev/null || top'

# 网络工具
alias ping='ping -c 5'
alias wget='wget -c'
alias curl='curl -L'

# Tmux 快捷键
alias tmux='tmux -2'
alias tma='tmux attach'
alias tms='tmux new-session -s'
alias tml='tmux list-sessions'

# 编辑器快捷键
alias vi='vim'
alias nano='nano -w'

# Claude Code 增强
if command -v claude &> /dev/null; then
    alias ccdsp='claude --dangerously-skip-permissions'
fi

# ============ 实用函数 ============

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# 快速查找文件
ff() {
    if command -v fd &> /dev/null; then
        fd "$1"
    else
        find . -name "*$1*" -type f
    fi
}

# 快速查找目录
fd_dir() {
    if command -v fd &> /dev/null; then
        fd -t d "$1"
    else
        find . -name "*$1*" -type d
    fi
}

# 提取各种压缩文件
extract() {
    if [ -f "$1" ] ; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' 无法提取，不支持的格式" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 搜索历史命令
search_history() {
    if command -v mcfly &> /dev/null; then
        mcfly search "$1"
    elif command -v hstr &> /dev/null; then
        hstr "$1"
    else
        history | grep "$1"
    fi
}

# 快速启动功能提示
show_tools() {
    echo -e "${GREEN}🚀 现代化Shell工具已加载！${NC}"
    echo -e "${BLUE}📁 目录导航:${NC} z <目录名> (智能跳转), zi (交互选择)"
    echo -e "${BLUE}🔍 文件搜索:${NC} Ctrl+T (文件), Alt+C (目录), Ctrl+R (历史)"
    echo -e "${BLUE}📋 文件查看:${NC} ll (详细列表), cat (语法高亮), grep (高级搜索)"
    echo -e "${BLUE}⚡ 实用函数:${NC} mkcd, extract, ff (查找文件)"
    echo -e "${BLUE}🎨 终端美化:${NC} Starship 提示符, 彩色输出"
}

# 自动显示工具提示（仅在交互式shell中）
if [[ $- == *i* ]]; then
    show_tools
fi

# ============ 补全增强 ============

# bash补全设置
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Git补全
if [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi

# 设置补全选项
set show-all-if-ambiguous on
set show-all-if-unmodified on
set completion-ignore-case on
set completion-query-items 200
set page-completions off

EOF

    success "现代化配置文件生成完成"
}

# 更新bashrc
update_bashrc() {
    info "更新 .bashrc 配置..."
    
    # 检查是否已经添加了我们的配置
    if ! grep -q "Modern Shell Configuration" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

# ============ Modern Shell Configuration ============
# 现代化Shell配置 - 自动生成，请勿手动修改此部分

# 加载现代化配置
if [ -f ~/.config/shell/modern-config.sh ]; then
    source ~/.config/shell/modern-config.sh
fi

# ============ End Modern Configuration ============
EOF
        success "已将现代化配置添加到 .bashrc"
    else
        info ".bashrc 已包含现代化配置，跳过更新"
    fi
}

# 生成Starship配置
generate_starship_config() {
    info "生成 Starship 配置..."
    
    mkdir -p "$HOME/.config"
    cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship 配置文件

format = """
[╭─user───❯](bold blue) $env_var\
$username\
[@ ](bold blue)\
$hostname\
[ in ](bold blue)\
$directory\
$git_branch\
$git_status\
$cmd_duration
[╰─](bold blue)$character"""

[username]
style_user = "green bold"
style_root = "red bold"
format = "[$user]($style)"
disabled = false
show_always = true

[hostname]
ssh_only = false
format = "[$hostname](bold red)"
disabled = false

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold cyan"

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
vicmd_symbol = "[❮](green)"

[git_branch]
symbol = "🌱 "
format = "[$symbol$branch]($style) "
style = "bright-green"

[git_status]
format = '[\[$all_status$ahead_behind\]]($style) '
style = "cyan"

[cmd_duration]
format = " took [$duration]($style)"
style = "yellow"

[battery]
full_symbol = "🔋 "
charging_symbol = "⚡️ "
discharging_symbol = "💀 "

[[battery.display]]
threshold = 10
style = "bold red"

[[battery.display]]
threshold = 30
style = "bold yellow"

[memory_usage]
disabled = false
threshold = -1
symbol = " "
style = "bold dimmed green"
EOF

    success "Starship 配置生成完成"
}

# 设置权限
set_permissions() {
    info "设置文件权限..."
    chmod +x "$CONFIG_DIR/modern-config.sh"
    success "权限设置完成"
}

# 显示安装结果
show_result() {
    success "=========================================="
    success "🎉 现代化Bash配置安装完成！"
    success "=========================================="
    echo
    info "安装的工具和功能："
    echo "✅ 现代化文件查看 (exa, bat)"
    echo "✅ 智能目录导航 (zoxide)"
    echo "✅ 模糊搜索 (fzf)"
    echo "✅ 高级搜索 (ripgrep, fd)"
    echo "✅ 历史增强 (hstr, mcfly)"
    echo "✅ 美化提示符 (starship)"
    echo "✅ Git 集成和别名"
    echo "✅ 实用函数和别名"
    echo
    info "配置文件位置："
    echo "📁 主配置: ~/.config/shell/modern-config.sh"
    echo "📁 备份: $BACKUP_DIR"
    echo "📁 日志: $INSTALL_LOG"
    echo
    warning "请运行以下命令应用新配置："
    echo "source ~/.bashrc"
    echo
    info "或者重新登录/重启终端"
    echo
    info "使用 'show_tools' 命令查看所有功能"
}

# 卸载函数
uninstall() {
    info "开始卸载现代化Bash配置..."
    
    # 恢复备份
    if [[ -d "$BACKUP_DIR" ]]; then
        info "恢复配置备份..."
        for file in .bashrc .bash_aliases .bash_profile .profile .inputrc .dircolors; do
            if [[ -f "$BACKUP_DIR/$file" ]]; then
                cp "$BACKUP_DIR/$file" "$HOME/"
                info "恢复 $file"
            fi
        done
    fi
    
    # 删除配置目录
    if [[ -d "$CONFIG_DIR" ]]; then
        rm -rf "$CONFIG_DIR"
        info "删除配置目录"
    fi
    
    # 删除Starship配置
    if [[ -f "$HOME/.config/starship.toml" ]]; then
        rm -f "$HOME/.config/starship.toml"
        info "删除Starship配置"
    fi
    
    success "卸载完成"
}

# 主函数
main() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    现代化Bash配置安装脚本"
    echo "    Modern Bash Configuration Installer"
    echo "    Version 1.0.0"
    echo "=========================================="
    echo -e "${NC}"
    
    # 解析命令行参数
    case "${1:-install}" in
        "install")
            check_system
            create_backup
            install_dependencies
            generate_config
            update_bashrc
            generate_starship_config
            set_permissions
            show_result
            ;;
        "uninstall")
            uninstall
            ;;
        "backup")
            create_backup
            success "配置备份完成: $BACKUP_DIR"
            ;;
        *)
            echo "用法: $0 [install|uninstall|backup]"
            echo "  install   - 安装现代化配置 (默认)"
            echo "  uninstall - 卸载并恢复原配置"
            echo "  backup    - 仅创建当前配置备份"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"