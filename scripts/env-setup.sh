#!/usr/bin/env bash
# 快速环境设置脚本
set -e

echo "🚀 Setting up development environment..."

# 检测操作系统
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    IS_WINDOWS=true
    VENV_PYTHON="./backend/.venv/Scripts/python"
    VENV_RUFF="./backend/.venv/Scripts/ruff"
    VENV_MYPY="./backend/.venv/Scripts/mypy"
else
    IS_WINDOWS=false
    VENV_PYTHON="./backend/.venv/bin/python"
    VENV_RUFF="./backend/.venv/bin/ruff"
    VENV_MYPY="./backend/.venv/bin/mypy"
fi

echo "🖥️  Detected OS: $(if $IS_WINDOWS; then echo "Windows"; else echo "Unix-like"; fi)"

# 检查并安装依赖
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 后端环境设置
echo "📦 Setting up backend dependencies..."
cd backend
uv sync
echo "✅ Backend dependencies installed"

# 安装 pre-commit
echo "🔧 Installing pre-commit hooks..."
uv run pre-commit install
uv run pre-commit install --hook-type commit-msg
echo "✅ Pre-commit hooks installed"

cd ..

# VSCode 配置
if [ ! -d .vscode ]; then
    echo "🔧 Setting up VSCode configuration..."
    mkdir -p .vscode

    # 创建推荐扩展配置
    cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "charliermarsh.ruff",
    "ms-python.mypy-type-checker",
    "ms-azuretools.vscode-docker",
    "humao.rest-client",
    "vivaxy.vscode-conventional-commits"
  ]
}
EOF

    # 创建 Python 解释器配置（根据操作系统设置路径）
    cat > .vscode/settings.json << EOF
{
  "python.defaultInterpreterPath": "$VENV_PYTHON",
  "python.terminal.activateEnvironment": true,
  "ruff.path": ["$VENV_RUFF"],
  "ruff.fixAll": true,
  "ruff.organizeImports": true,
  "mypy-type-checker.path": ["$VENV_MYPY"],
  "mypy-type-checker.importStrategy": "fromEnvironment",
  "python.analysis.typeCheckingMode": "off",
  "python.linting.enabled": false,
  "python.formatting.provider": "none",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.ruff": "explicit",
      "source.organizeImports.ruff": "explicit"
    }
  },
  "files.exclude": {
    "**/__pycache__": true,
    "**/.pytest_cache": true,
    "**/.mypy_cache": true,
    "**/.ruff_cache": true
  }
}
EOF
    echo "✅ VSCode configuration created"
fi

# 代码质量检查
echo "🔍 Running initial code quality checks..."
cd backend
if uv run pre-commit run --all-files; then
    echo "✅ All pre-commit checks passed"
else
    echo "⚠️  Some pre-commit checks failed. Please review and fix the issues."
fi
cd ..

echo ""
echo "🎉 Environment setup complete!"
echo ""
echo "Next steps:"
echo "1. 📝 Edit .env file with your configuration"
echo "2. 🚀 Start development with: docker compose watch"
echo "3. 🌐 Access API docs at: http://localhost:8000/docs"
echo "4. 🗄️  Access database admin at: http://localhost:8080"
echo ""
echo "Useful commands:"
echo "- Start full stack: docker compose watch"
echo "- Run tests: ./scripts/test.sh"
echo "- Format code: cd backend && uv run ruff format ."
echo "- Check code: cd backend && uv run ruff check . --fix"
