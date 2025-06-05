#!/usr/bin/env bash
# 版本升级脚本
set -e

echo "🔄 Version bump with Commitizen..."

cd backend

# 显示当前版本
echo "📍 Current version: $(uv run cz version)"

# 执行版本升级
if [ $# -eq 0 ]; then
    echo "🚀 Auto-detecting version bump..."
    uv run cz bump --changelog --changelog-to-stdout > ../CHANGELOG.md
else
    echo "🚀 Bumping version with: $1"
    uv run cz bump --increment "$1" --changelog --changelog-to-stdout > ../CHANGELOG.md
fi

cd ..
echo "✅ Version bump completed"
