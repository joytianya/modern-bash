# 现代化Bash配置安装器

一键安装脚本，让你的bash环境现代化，包含所有你当前使用的优化配置。

## 快速开始

### 通用安装器 (推荐)
```bash
# 下载并运行通用安装器
curl -O https://raw.githubusercontent.com/joytianya/modern-bash/main/universal-installer.sh
chmod +x universal-installer.sh
./universal-installer.sh
```

### macOS Terminal.app 专用安装器
```bash
# 针对 macOS Terminal.app 优化的安装器
curl -O https://raw.githubusercontent.com/joytianya/modern-bash/main/mac-terminal-installer.sh
chmod +x mac-terminal-installer.sh
./mac-terminal-installer.sh
```

### 在线一键安装
```bash
# 通用版本
bash <(curl -s https://raw.githubusercontent.com/joytianya/modern-bash/main/universal-installer.sh)

# macOS Terminal.app 版本
bash <(curl -s https://raw.githubusercontent.com/joytianya/modern-bash/main/mac-terminal-installer.sh)
```

## 功能特性

### 🚀 现代化工具
- **exa**: 现代化的 `ls` 命令，支持图标和Git状态
- **bat**: 现代化的 `cat` 命令，支持语法高亮
- **fzf**: 强大的模糊搜索工具
- **zoxide**: 智能目录跳转，替代 `cd`
- **ripgrep**: 超快的搜索工具
- **fd**: 现代化的 `find` 命令
- **hstr**: 历史命令搜索增强
- **mcfly**: 智能历史管理
- **starship**: 美化的跨shell提示符

### 📋 智能别名
```bash
# 文件操作
ll          # exa -la --icons (详细列表)
la          # exa -a --icons (显示隐藏文件)
cat         # bat --paging=never (语法高亮)
grep        # rg (超快搜索)
find        # fd (现代查找)

# 目录导航
cd          # z (智能跳转)
cdi         # zi (交互选择)
..          # cd ..
...         # cd ../..

# Git快捷键
gs          # git status
ga          # git add
gc          # git commit
gl          # git log --oneline --graph
gp          # git push

# 系统信息
df          # df -h (易读格式)
du          # du -h 
free        # free -h
ps          # ps aux
```

### ⚡ 实用函数
```bash
mkcd <dir>          # 创建目录并进入
extract <file>      # 智能解压各种格式
ff <pattern>        # 快速查找文件
show_tools          # 显示所有可用工具
search_history      # 搜索命令历史
```

### 🎯 快捷键
- `Ctrl+T`: 模糊搜索文件
- `Alt+C`: 模糊搜索目录
- `Ctrl+R`: 搜索命令历史 (增强版)

## 安装选项

### 通用安装器选项
```bash
# 完整安装 (默认)
./universal-installer.sh install

# 仅创建备份
./universal-installer.sh backup

# 卸载并恢复
./universal-installer.sh uninstall
```

### macOS Terminal.app 安装器选项
```bash
# 完整安装 (默认)
./mac-terminal-installer.sh install

# 仅创建备份
./mac-terminal-installer.sh backup

# 卸载并恢复
./mac-terminal-installer.sh uninstall
```

## 支持的系统

### Shell 环境支持
- **bash**: 完全支持
- **zsh**: 完全支持
- **fish**: 基础支持

### 操作系统支持
- **Linux**: Ubuntu, Debian, CentOS, Arch Linux
- **macOS**: 通过 Homebrew (提供专用安装器)
- **其他**: 手动安装模式

## 安装内容

### 配置文件
- `~/.config/shell/modern-config.sh` - 主配置文件
- `~/.config/starship.toml` - Starship提示符配置
- 自动更新 `~/.bashrc`

### 备份机制
- 自动备份现有配置到 `~/.config_backup_YYYYMMDD_HHMMSS/`
- 支持一键恢复
- 安装日志记录在 `~/bash_installer.log`

### 包管理器支持
- **Ubuntu/Debian**: apt
- **CentOS/RHEL**: yum
- **Arch Linux**: pacman  
- **macOS**: brew

## 卸载

### 通用安装器卸载
```bash
./universal-installer.sh uninstall
```

### macOS Terminal.app 安装器卸载
```bash
./mac-terminal-installer.sh uninstall
```

这将：
1. 恢复原始配置文件
2. 删除新增的配置目录
3. 保留安装的工具（可手动删除）

## 自定义配置

安装后，你可以编辑 `~/.config/shell/modern-config.sh` 来自定义：
- 添加个人别名
- 修改工具配置
- 调整颜色主题

## 故障排除

### 权限问题
```bash
# 通用安装器
chmod +x universal-installer.sh

# macOS Terminal.app 安装器
chmod +x mac-terminal-installer.sh
```

### 工具未找到
某些工具可能需要手动添加到 PATH，或重新登录终端。

### 配置不生效
```bash
# bash 用户
source ~/.bashrc

# zsh 用户
source ~/.zshrc

# 或重启终端
```

### 查看日志
```bash
cat ~/bash_installer.log
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License