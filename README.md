# 现代化Bash配置安装器

一键安装脚本，让你的bash环境现代化，包含所有你当前使用的优化配置。

## 快速开始

```bash
# 下载并运行安装脚本
curl -O https://raw.githubusercontent.com/your-repo/modern-bash-installer.sh
chmod +x modern-bash-installer.sh
./modern-bash-installer.sh
```

或者直接运行：
```bash
bash <(curl -s https://raw.githubusercontent.com/your-repo/modern-bash-installer.sh)
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

```bash
# 完整安装 (默认)
./modern-bash-installer.sh install

# 仅创建备份
./modern-bash-installer.sh backup

# 卸载并恢复
./modern-bash-installer.sh uninstall
```

## 支持的系统

- **Linux**: Ubuntu, Debian, CentOS, Arch Linux
- **macOS**: 通过 Homebrew
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

```bash
./modern-bash-installer.sh uninstall
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
chmod +x modern-bash-installer.sh
```

### 工具未找到
某些工具可能需要手动添加到 PATH，或重新登录终端。

### 配置不生效
```bash
source ~/.bashrc
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