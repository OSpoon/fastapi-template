#!/usr/bin/env bash
# 快速环境设置脚本
set -e

echo "Setting up development environment..."

# 检查并安装依赖
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 后端环境设置
cd backend
uv sync
echo "Backend dependencies installed"

# 安装 pre-commit
uv run pre-commit install
echo "Pre-commit hooks installed"

cd ..
echo "Environment setup complete!"
