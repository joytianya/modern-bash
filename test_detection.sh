#!/bin/bash

# 测试工具检测机制的简单脚本

echo "=== 工具检测测试 ==="

for tool in curl git tmux vim fzf exa bat rg fd zoxide starship mcfly; do
    printf "%-10s: " "$tool"
    if command -v "$tool" &> /dev/null; then
        echo "✅ 已安装，跳过"
    else
        echo "❌ 未安装，需要安装"
    fi
done

echo
echo "=== 配置文件检测测试 ==="

CONFIG_DIR="$HOME/.config/shell"
printf "%-25s: " "modern-config.sh"
if [ -f "$CONFIG_DIR/modern-config.sh" ]; then
    echo "✅ 已存在，跳过生成"
else
    echo "❌ 不存在，需要生成"
fi

printf "%-25s: " "starship.toml"
if [ -f "$HOME/.config/starship.toml" ]; then
    echo "✅ 已存在，跳过生成"
else
    echo "❌ 不存在，需要生成"
fi

printf "%-25s: " ".bashrc 现代化配置"
if grep -q "Modern Shell Configuration" "$HOME/.bashrc" 2>/dev/null; then
    echo "✅ 已添加，跳过更新"
else
    echo "❌ 未添加，需要更新"
fi