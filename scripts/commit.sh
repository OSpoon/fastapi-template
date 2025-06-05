#!/usr/bin/env bash
# 交互式提交脚本
set -e

echo "🚀 Interactive commit with Commitizen..."

# 检查是否有暂存的更改
if ! git diff --cached --quiet; then
    echo "📝 Starting interactive commit..."
    cd backend
    uv run cz commit
    cd ..
else
    echo "❌ No staged changes found. Please stage your changes first with:"
    echo "   git add <files>"
    exit 1
fi
