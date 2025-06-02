# FastAPI 项目快速指南

一个现代化的 FastAPI 后端项目模板，包含完整的开发和部署流程。

---

> **📌 重要声明**
>
> 本项目基于 [fastapi/full-stack-fastapi-template](https://github.com/fastapi/full-stack-fastapi-template) 进行精简，专注于后端 API 开发。
>
> **主要变更**：
> - ✅ 保留：FastAPI 后端、数据库、认证、测试、部署
> - ❌ 移除：前端 React 应用及相关配置
> - 🔧 优化：简化了开发流程和配置文件

---

## 🚀 快速开始

### 前置要求

- [Docker](https://www.docker.com/) - 容器化部署
- [Git](https://git-scm.com/) - 版本控制
- [Python 3.10+](https://www.python.org/) - 后端语言
- [uv](https://docs.astral.sh/uv/) - Python 包管理器

### 安装 uv

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

## 📦 项目创建

### 方式一：直接克隆（推荐）

```bash
# 克隆项目
git clone https://github.com/your-username/fastapi-template.git my-project
cd my-project

# 重新初始化 Git
rm -rf .git
git init
git add .
git commit -m "Initial commit"
```

### 方式二：GitHub 模板

1. 点击 GitHub 页面的 "Use this template" 按钮
2. 创建新仓库
3. 克隆你的新仓库

## ⚙️ 项目初始化

### 1. 环境配置

```bash
# 复制环境变量文件
cp .env.example .env

# 编辑配置（重要！）
vim .env  # 或使用你喜欢的编辑器
```

**必须修改的配置项：**
```env
# 项目信息
PROJECT_NAME=我的FastAPI项目
DOMAIN=localhost.ospoon.cn

# 安全密钥（生成新的！）
SECRET_KEY=your-secret-key-here

# 数据库
POSTGRES_PASSWORD=your-db-password

# 超级管理员
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=your-admin-password

# 前端主机（CORS配置）
FRONTEND_HOST=http://localhost:3000
```

### 2. 生成安全密钥

```bash
# 生成SECRET_KEY
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### 3. 安装依赖

```bash
# 进入后端目录
cd backend

# 安装依赖
uv sync

# 激活虚拟环境
source .venv/bin/activate

# 安装 pre-commit 钩子
uv run pre-commit install
```

## 🔧 开发环境

### 启动开发服务

```bash
# 启动完整堆栈（推荐）
docker compose watch

# 或者只启动数据库，手动运行后端
docker compose up -d db
cd backend
fastapi dev app/main.py
```

### 访问地址

- **后端 API**: http://localhost:8000
- **API 文档**: http://localhost:8000/docs
- **数据库管理**: http://localhost:8080
- **Traefik 面板**: http://localhost:8090
- **邮件捕获**: http://localhost:1080

### 检查服务状态

```bash
# 查看所有服务日志
docker compose logs

# 查看特定服务
docker compose logs backend

# 健康检查
curl http://localhost:8000/api/v1/utils/health-check
```

## 🧪 测试

### 运行测试

```bash
# 运行所有测试
./scripts/test.sh

# 在运行的堆栈中测试
docker compose exec backend bash scripts/tests-start.sh

# 带覆盖率报告
./scripts/test-local.sh
```

### 代码质量检查

```bash
# 手动运行 pre-commit
uv run pre-commit run --all-files

# 代码格式化
cd backend
uv run ruff format .

# 代码检查
uv run ruff check . --fix
```

## 🗄️ 数据库管理

### 数据库迁移

```bash
# 进入后端容器
docker compose exec backend bash

# 创建迁移
alembic revision --autogenerate -m "描述你的更改"

# 应用迁移
alembic upgrade head

# 查看迁移历史
alembic history
```

### 重置数据库

```bash
# 完全重置（谨慎使用！）
docker compose down -v
docker compose up -d db
docker compose exec backend alembic upgrade head
```

## 📝 开发流程

### 1. 添加新的 API 端点

```python
# backend/app/api/routes/your_feature.py
from fastapi import APIRouter

router = APIRouter()

@router.get("/")
def get_items():
    return {"message": "Hello World"}
```

### 2. 添加数据模型

```python
# backend/app/models.py
from sqlmodel import SQLModel, Field

class Item(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    description: str | None = None
```

### 3. 添加 CRUD 操作

```python
# backend/app/crud.py
from sqlmodel import Session, select
from app.models import Item

def create_item(*, session: Session, item_create: ItemCreate) -> Item:
    item = Item.model_validate(item_create)
    session.add(item)
    session.commit()
    session.refresh(item)
    return item
```

### 4. 注册路由

```python
# backend/app/api/main.py
from app.api.routes import your_feature

api_router.include_router(
    your_feature.router,
    prefix="/your-feature",
    tags=["your-feature"]
)
```

## 🚀 部署

### 环境配置

```bash
# 生产环境变量
export ENVIRONMENT=production
export DOMAIN=yourdomain.com
export SECRET_KEY=$(python -c "import secrets; print(secrets.token_urlsafe(32))")
export POSTGRES_PASSWORD=your-secure-password
```

### Docker 部署

```bash
# 构建镜像
TAG=v1.0.0 ./scripts/build.sh

# 部署
docker compose -f docker-compose.yml up -d
```

### CI/CD 部署

1. **设置 GitHub Secrets**：
   - `SECRET_KEY`
   - `POSTGRES_PASSWORD`
   - `FIRST_SUPERUSER_PASSWORD`
   - `DOMAIN_PRODUCTION`

2. **推送代码触发部署**：
   ```bash
   git push origin main  # 部署到 staging
   git tag v1.0.0 && git push origin v1.0.0  # 部署到 production
   ```

## 🔍 常用命令

### Docker 相关

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启特定服务
docker compose restart backend

# 查看日志
docker compose logs -f backend

# 进入容器
docker compose exec backend bash

# 清理资源
docker compose down -v --remove-orphans
```

### 开发工具

```bash
# 格式化代码
uv run ruff format backend/

# 代码检查
uv run ruff check backend/ --fix

# 类型检查
uv run mypy backend/

# 运行测试
uv run pytest backend/app/tests/

# 生成密钥
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

## 🛠️ VSCode 配置

### 推荐插件

创建 `.vscode/extensions.json`：

```json
{
  "recommendations": [
    "ms-python.python",
    "charliermarsh.ruff",
    "ms-azuretools.vscode-docker",
    "humao.rest-client",
    "eamodio.gitlens"
  ]
}
```

### Python 解释器设置

1. 打开 VSCode
2. `Ctrl+Shift+P` → "Python: Select Interpreter"
3. 选择 `./backend/.venv/bin/python`

## 🐛 常见问题

### 1. 端口已被占用

```bash
# 查看端口使用
lsof -i :8000

# 停止所有 Docker 容器
docker compose down
```

### 2. 数据库连接失败

```bash
# 检查数据库状态
docker compose ps db

# 重启数据库
docker compose restart db
```

### 3. 权限错误

```bash
# 给脚本添加执行权限
chmod +x scripts/*.sh
```

### 4. 清理 Docker 资源

```bash
# 清理未使用的资源
docker system prune -f

# 清理所有数据
docker compose down -v --remove-orphans
```

## 📚 技术栈

- **后端**: FastAPI + SQLModel + PostgreSQL
- **认证**: JWT + 密码哈希
- **测试**: Pytest + 覆盖率报告
- **部署**: Docker Compose + Traefik
- **CI/CD**: GitHub Actions
- **代码质量**: Ruff + Pre-commit

## 📞 获取帮助

- [FastAPI 文档](https://fastapi.tiangolo.com/)
- [SQLModel 文档](https://sqlmodel.tiangolo.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
