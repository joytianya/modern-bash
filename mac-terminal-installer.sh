#!/bin/bash

# Modern Bash Configuration Installer for Mac Terminal
# Mac 终端现代化 Bash 配置一键安装脚本
# Author: zxw
# Version: 1.0.0 (Mac Optimized)

set -e

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.config/shell"
INSTALL_LOG="$HOME/bash_installer_mac.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# 检查 Mac 系统
check_mac_system() {
    info "检查 Mac 系统环境..."

    # 确认是 macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "此脚本仅适用于 macOS 系统"
        exit 1
    fi

    # 检查系统版本
    MAC_VERSION=$(sw_vers -productVersion)
    info "检测到 macOS 版本: $MAC_VERSION"

    # 检查 Homebrew
    if ! command -v brew &> /dev/null; then
        warning "未检测到 Homebrew，开始安装..."
        install_homebrew
    else
        info "Homebrew 已安装，版本: $(brew --version | head -1)"
    fi

    # 检查 Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        warning "未检测到 Xcode Command Line Tools，开始安装..."
        xcode-select --install
        info "请按照提示完成 Xcode Command Line Tools 安装，然后重新运行此脚本"
        exit 1
    else
        info "Xcode Command Line Tools 已安装"
    fi
}

# 安装 Homebrew
install_homebrew() {
    info "正在安装 Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        success "Homebrew 安装成功"

        # 添加 Homebrew 到 PATH（适配 Apple Silicon 和 Intel Mac）
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        source ~/.bash_profile
    else
        error "Homebrew 安装失败"
        exit 1
    fi
}

# 创建备份
create_backup() {
    info "创建配置备份到 $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"

    # 备份现有配置文件（Mac 特定）
    for file in .bashrc .bash_aliases .bash_profile .profile .inputrc .dircolors .zshrc; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$BACKUP_DIR/"
            info "备份 $file"
        fi
    done

    success "配置备份完成"
}

# 安装现代化工具（Mac 优化版本）
install_mac_tools() {
    info "安装现代化 Shell 工具..."

    # 更新 Homebrew
    info "更新 Homebrew..."
    brew update

    # 定义工具列表（Mac 优化）
    declare -A TOOLS=(
        ["git"]="版本控制"
        ["fzf"]="模糊搜索"
        ["zoxide"]="智能目录跳转"
        ["eza"]="现代化 ls (exa 的继任者)"
        ["bat"]="现代化 cat"
        ["ripgrep"]="现代化 grep"
        ["fd"]="现代化 find"
        ["tmux"]="终端多路复用器"
        ["vim"]="文本编辑器"
        ["htop"]="系统监控"
        ["tree"]="目录树显示"
        ["wget"]="文件下载工具"
        ["jq"]="JSON 处理工具"
        ["tldr"]="简化版 man 页面"
        ["ncdu"]="磁盘使用分析"
        ["procs"]="现代化 ps"
        ["dust"]="现代化 du"
        ["bandwhich"]="网络监控"
    )

    # 检查并安装工具
    TOOLS_TO_INSTALL=""
    for tool in "${!TOOLS[@]}"; do
        if ! command -v $tool &> /dev/null; then
            TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL $tool"
            info "将安装 $tool - ${TOOLS[$tool]}"
        else
            info "$tool 已安装，跳过"
        fi
    done

    if [ -n "$TOOLS_TO_INSTALL" ]; then
        info "开始安装工具: $TOOLS_TO_INSTALL"
        brew install $TOOLS_TO_INSTALL
        success "工具安装完成"
    else
        info "所有工具都已安装，跳过 brew 安装"
    fi

    # 安装 Starship
    if ! command -v starship &> /dev/null; then
        info "安装 Starship 终端提示符..."
        brew install starship
        success "Starship 安装成功"
    else
        info "Starship 已安装，跳过"
    fi

    # 安装 McFly
    if ! command -v mcfly &> /dev/null; then
        info "安装 McFly 智能历史管理..."
        if brew install mcfly 2>/dev/null; then
            success "McFly 安装成功"
        else
            warning "McFly 安装失败，请检查 Homebrew 或手动安装"
        fi
    else
        info "McFly 已安装，跳过"
    fi

    # 安装字体（可选）
    info "安装 Nerd 字体以获得更好的图标支持..."
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code-nerd-font 2>/dev/null || warning "字体安装失败，不影响主要功能"
}

# 生成 Mac 优化配置
generate_mac_config() {
    info "生成 Mac 优化的现代化 Bash 配置..."

    mkdir -p "$CONFIG_DIR"

    # 检查配置文件是否已存在
    if [ -f "$CONFIG_DIR/modern-config-mac.sh" ]; then
        info "Mac 现代化配置文件已存在，跳过生成"
        return 0
    fi

    # 生成主配置文件
    cat > "$CONFIG_DIR/modern-config-mac.sh" << 'EOF'
#!/bin/bash
# Modern Shell Configuration for Mac
# Mac 现代化 Shell 配置

# ============ Mac 特定配置 ============

# Homebrew 环境配置
if [[ $(uname -m) == 'arm64' ]]; then
    # Apple Silicon Mac
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    # Intel Mac
    eval "$(/usr/local/bin/brew shellenv)"
fi

# 启用别名扩展
shopt -s expand_aliases

# 历史配置优化
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoredups:ignorespace:erasedups
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend
shopt -s checkwinsize
shopt -s histverify

# Mac 特定环境变量
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# 设置 UTF-8 编码
export LANG=en_US.UTF-8
# 检查并设置 LC_ALL（避免在不支持的系统上出错）
if locale -a 2>/dev/null | grep -q "en_US.UTF-8"; then
    export LC_ALL=en_US.UTF-8
elif locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    export LC_ALL=en_US.utf8
else
    export LC_ALL=C.UTF-8
fi

# ============ 现代化工具配置 ============

# FZF - 模糊搜索配置（Mac 优化）
export FZF_DEFAULT_OPTS='
    --height 50%
    --layout=reverse
    --border=rounded
    --preview "bat --style=numbers --color=always --line-range :500 {}"
    --preview-window=right:50%:wrap
    --bind "ctrl-/:toggle-preview"
    --bind "ctrl-u:preview-page-up"
    --bind "ctrl-d:preview-page-down"
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules --exclude .DS_Store'

# 加载 FZF 键绑定（Mac Homebrew 路径）
if [[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.bash" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/key-bindings.bash"
fi

if [[ -f "$(brew --prefix)/opt/fzf/shell/completion.bash" ]]; then
    source "$(brew --prefix)/opt/fzf/shell/completion.bash"
fi

# Zoxide - 智能目录跳转
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# McFly - 智能历史管理
if command -v mcfly &> /dev/null; then
    eval "$(mcfly init bash)"
    export MCFLY_KEY_SCHEME=vim
    export MCFLY_FUZZY=2
    export MCFLY_RESULTS=50
    export MCFLY_INTERFACE_VIEW=BOTTOM
fi

# Starship - 美化终端提示符
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# ============ Mac 特定别名 ============

# macOS 系统别名
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias battery='pmset -g batt'
alias cpu='top -l 1 -s 0 | grep "CPU usage"'
alias meminfo='vm_stat'
alias ports='lsof -i -P | grep LISTEN'
alias brewup='brew update && brew upgrade && brew cleanup'

# 快速打开应用
alias code='open -a "Visual Studio Code"'
alias xcode='open -a "Xcode"'
alias finder='open -a "Finder"'

# 现代化命令替换
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --time-style=long-iso --git'
    alias la='eza -a --icons --group-directories-first'
    alias l='eza --icons --group-directories-first'
    alias lt='eza -la --icons --sort=modified --git'
    alias lh='eza -la --icons --group-directories-first --git'
    alias lta='eza --tree --level=3 --icons --git-ignore'
else
    alias ls='ls -G --color=auto'
    alias ll='ls -alFG --color=auto'
    alias la='ls -AG --color=auto'
    alias l='ls -CFG --color=auto'
fi

# 现代化 cat
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias bcat='bat'
    export BAT_THEME="Dracula"
fi

# 现代化 grep
if command -v rg &> /dev/null; then
    alias grep='rg --color=auto'
    alias rg='rg --colors "match:bg:yellow" --colors "match:fg:black" --colors "match:style:nobold" --colors "path:fg:green" --colors "path:style:bold" --colors "line:fg:cyan"'
fi

# 现代化 find
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# 现代化系统命令
if command -v procs &> /dev/null; then
    alias ps='procs'
fi

if command -v dust &> /dev/null; then
    alias du='dust'
fi

if command -v htop &> /dev/null; then
    alias top='htop'
fi

# Git 增强别名
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gdc='git diff --cached'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git remote -v'

# 目录导航增强
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Zoxide 别名
if command -v zoxide &> /dev/null; then
    alias cd='z'
    alias cdi='zi'
fi

# 文件操作安全化
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# 网络工具
alias ping='ping -c 5'
alias wget='wget -c'
alias curl='curl -L'
alias ip='curl -s ipinfo.io/ip'
alias localip='ipconfig getifaddr en0'
alias ips='ifconfig | grep "inet " | grep -v 127.0.0.1'

# 压缩和解压
alias tgz='tar -czf'
alias untgz='tar -xzf'

# 清理和维护
alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'
alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'

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
fdir() {
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
            *.dmg)       hdiutil mount "$1" ;;
            *)           echo "'$1' 无法提取，不支持的格式" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 快速创建备份
backup() {
    if [ -n "$1" ]; then
        cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
        echo "备份创建: $1.backup-$(date +%Y%m%d-%H%M%S)"
    else
        echo "用法: backup <文件名>"
    fi
}

# 查看文件夹大小
dirsize() {
    if command -v dust &> /dev/null; then
        dust -d 1 "${1:-.}"
    else
        du -sh "${1:-.}"/* | sort -hr
    fi
}

# 端口检查
port() {
    if [ -n "$1" ]; then
        lsof -i ":$1"
    else
        echo "用法: port <端口号>"
    fi
}

# 快速启动 HTTP 服务器
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# 显示系统信息
sysinfo() {
    echo -e "${GREEN}🍎 Mac 系统信息${NC}"
    echo "操作系统: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo "处理器: $(sysctl -n machdep.cpu.brand_string)"
    echo "内存: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    echo "磁盘使用: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
    echo "正常运行时间: $(uptime | sed 's/.*up //' | sed 's/,.*//')"
}

# 快速启动功能提示
show_mac_tools() {
    echo -e "${GREEN}🚀 Mac 现代化 Shell 工具已加载！${NC}"
    echo -e "${BLUE}📁 目录导航:${NC} z <目录名> (智能跳转), zi (交互选择)"
    echo -e "${BLUE}🔍 文件搜索:${NC} Ctrl+T (文件), Alt+C (目录), Ctrl+R (历史)"
    echo -e "${BLUE}📋 文件查看:${NC} ll (详细列表), cat (语法高亮), grep (高级搜索)"
    echo -e "${BLUE}⚡ 实用函数:${NC} mkcd, extract, ff (查找文件), sysinfo"
    echo -e "${BLUE}🍎 Mac 特定:${NC} flushdns, showfiles, hidefiles, brewup"
    echo -e "${BLUE}🎨 终端美化:${NC} Starship 提示符, 彩色输出, Nerd 字体图标"
    echo -e "${PURPLE}💡 提示:${NC} 使用 'show_mac_tools' 随时查看此帮助"
}

# 自动显示工具提示（仅在交互式 shell 中）
if [[ $- == *i* ]]; then
    show_mac_tools
fi

# ============ Bash 补全增强 ============

# Homebrew bash 补全
if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# Git 补全
if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
    source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
fi

# 设置补全选项
bind "set show-all-if-ambiguous on"
bind "set show-all-if-unmodified on"
bind "set completion-ignore-case on"
bind "set completion-query-items 200"
bind "set page-completions off"

# ============ 性能优化 ============

# 禁用 macOS 的 bash 会话历史
export SHELL_SESSION_HISTORY=0

# 加快 Git 状态检查
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

EOF

    success "Mac 现代化配置文件生成完成"
}

# 更新 .bash_profile
update_bash_profile() {
    info "更新 .bash_profile 配置..."

    # 确保 .bash_profile 存在
    touch "$HOME/.bash_profile"

    # 检查是否已经添加了我们的配置
    if ! grep -q "Modern Shell Configuration for Mac" "$HOME/.bash_profile"; then
        cat >> "$HOME/.bash_profile" << 'EOF'

# ============ Modern Shell Configuration for Mac ============
# Mac 现代化 Shell 配置 - 自动生成，请勿手动修改此部分

# 加载现代化配置
if [ -f ~/.config/shell/modern-config-mac.sh ]; then
    source ~/.config/shell/modern-config-mac.sh
fi

# 兼容 .bashrc
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# ============ End Modern Configuration ============
EOF
        success "已将现代化配置添加到 .bash_profile"
    else
        info ".bash_profile 已包含现代化配置，跳过更新"
    fi
}

# 生成 Mac 优化的 Starship 配置
generate_mac_starship_config() {
    info "生成 Mac 优化的 Starship 配置..."

    mkdir -p "$HOME/.config"

    # 检查配置文件是否已存在
    if [ -f "$HOME/.config/starship.toml" ]; then
        info "Starship 配置文件已存在，跳过生成"
        return 0
    fi

    cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship 配置文件 - Mac 优化版

format = """
[╭─user───❯](bold blue) $os\
$username\
[@ ](bold blue)\
$hostname\
[ in ](bold blue)\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$golang\
$java\
$docker_context\
$cmd_duration
[╰─](bold blue)$character"""

[os]
disabled = false
style = "bg:blue fg:white"

[os.symbols]
Macos = "🍎 "

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
read_only = " 🔒"

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
min_time = 2000

[nodejs]
symbol = "⬢ "
style = "bold green"

[python]
symbol = "🐍 "
style = "bold yellow"

[rust]
symbol = "🦀 "
style = "bold red"

[golang]
symbol = "🐹 "
style = "bold cyan"

[java]
symbol = "☕ "
style = "bold red"

[docker_context]
symbol = "🐳 "
style = "bold blue"

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
threshold = 70
symbol = " "
style = "bold dimmed green"
EOF

    success "Mac Starship 配置生成完成"
}

# 设置权限
set_permissions() {
    info "设置文件权限..."
    chmod +x "$CONFIG_DIR/modern-config-mac.sh"
    success "权限设置完成"
}

# 显示安装结果
show_result() {
    success "=========================================="
    success "🎉 Mac 现代化 Bash 配置安装完成！"
    success "=========================================="
    echo
    info "安装的工具和功能："
    echo "✅ Homebrew 包管理器"
    echo "✅ 现代化文件查看 (eza, bat)"
    echo "✅ 智能目录导航 (zoxide)"
    echo "✅ 模糊搜索 (fzf)"
    echo "✅ 高级搜索 (ripgrep, fd)"
    echo "✅ 历史增强 (mcfly)"
    echo "✅ 美化提示符 (starship)"
    echo "✅ 系统监控 (htop, procs, dust)"
    echo "✅ Mac 特定功能和别名"
    echo "✅ Nerd 字体支持"
    echo "✅ Git 集成和别名"
    echo "✅ 实用函数和 Mac 优化"
    echo
    info "配置文件位置："
    echo "📁 主配置: ~/.config/shell/modern-config-mac.sh"
    echo "📁 备份: $BACKUP_DIR"
    echo "📁 日志: $INSTALL_LOG"
    echo "📁 Starship: ~/.config/starship.toml"
    echo
    warning "请运行以下命令应用新配置："
    echo "source ~/.bash_profile"
    echo
    info "或者重新打开终端窗口"
    echo
    info "使用 'show_mac_tools' 命令查看所有功能"
    echo
    success "享受你的现代化 Mac 终端体验！ 🚀"
}

# 卸载函数
uninstall() {
    info "开始卸载 Mac 现代化 Bash 配置..."

    # 恢复备份
    read -p "请输入要恢复的备份目录名称 (格式: .config_backup_YYYYMMDD_HHMMSS): " backup_name
    RESTORE_DIR="$HOME/$backup_name"

    if [[ -d "$RESTORE_DIR" ]]; then
        info "恢复配置备份..."
        for file in .bashrc .bash_aliases .bash_profile .profile .inputrc .dircolors .zshrc; do
            if [[ -f "$RESTORE_DIR/$file" ]]; then
                cp "$RESTORE_DIR/$file" "$HOME/"
                info "恢复 $file"
            fi
        done
    else
        warning "备份目录不存在，跳过恢复"
    fi

    # 删除配置目录
    if [[ -d "$CONFIG_DIR" ]]; then
        rm -rf "$CONFIG_DIR"
        info "删除配置目录"
    fi

    # 删除 Starship 配置
    if [[ -f "$HOME/.config/starship.toml" ]]; then
        rm -f "$HOME/.config/starship.toml"
        info "删除 Starship 配置"
    fi

    success "卸载完成"
}

# 主函数
main() {
    clear
    echo -e "${BLUE}"
    echo "=========================================="
    echo "    Mac 现代化 Bash 配置安装脚本"
    echo "  Modern Bash Configuration for Mac"
    echo "    Version 1.0.0 (Mac Optimized)"
    echo "=========================================="
    echo -e "${NC}"

    # 解析命令行参数
    case "${1:-install}" in
        "install")
            check_mac_system
            create_backup
            install_mac_tools
            generate_mac_config
            update_bash_profile
            generate_mac_starship_config
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
            echo "  install   - 安装 Mac 现代化配置 (默认)"
            echo "  uninstall - 卸载并恢复原配置"
            echo "  backup    - 仅创建当前配置备份"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"