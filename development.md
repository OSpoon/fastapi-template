# FastAPI 项目 - 开发

## Docker Compose

* 使用 Docker Compose 启动本地堆栈：

```bash
docker compose watch
```

* 现在你可以打开浏览器并与这些 URL 交互：

前端，使用 Docker 构建，路由根据路径处理： http://localhost:5173

后端，基于 OpenAPI 的 JSON Web API： http://localhost:8000

使用 Swagger UI 的自动交互式文档（来自 OpenAPI 后端）： http://localhost:8000/docs

Adminer，数据库 Web 管理： http://localhost:8080

Traefik UI，查看代理如何处理路由： http://localhost:8090

**注意**：第一次启动堆栈时，可能需要一分钟才能准备就绪。在此期间，后端等待数据库准备就绪并配置所有内容。你可以检查日志以监控它。

要检查日志，请运行（在另一个终端中）：

```bash
docker compose logs
```

要检查特定服务的日志，请添加服务名称，例如：

```bash
docker compose logs backend
```

## 本地开发

Docker Compose 文件已配置，以便每个服务在 `localhost` 的不同端口上可用。

对于后端和前端，它们使用与其本地开发服务器相同的端口，因此，后端位于 `http://localhost:8000`，前端位于 `http://localhost:5173`。

这样，你可以关闭 Docker Compose 服务并启动其本地开发服务，一切都会继续工作，因为它们都使用相同的端口。

例如，你可以在另一个终端中停止 Docker Compose 中的 `frontend` 服务，运行：

```bash
docker compose stop frontend
```

然后启动本地前端开发服务器：

```bash
cd frontend
npm run dev
```

或者你可以停止 `backend` Docker Compose 服务：

```bash
docker compose stop backend
```

然后你可以运行后端的本地开发服务器：

```bash
cd backend
fastapi dev app/main.py
```

## `localhost.ospoon.cn` 中的 Docker Compose

当你启动 Docker Compose 堆栈时，它默认使用 `localhost`，每个服务（后端、前端、adminer 等）使用不同的端口。

当你将其部署到生产（或预演）环境时，它会将每个服务部署在不同的子域中，例如后端的 `api.example.com` 和前端的 `dashboard.example.com`。

在关于[部署](deployment.md)的指南中，你可以阅读有关 Traefik（已配置的代理）的信息。该组件负责根据子域将流量传输到每个服务。

如果你想在本地测试一切是否正常工作，可以编辑本地 `.env` 文件，并更改：

```dotenv
DOMAIN=localhost.ospoon.cn
```

Docker Compose 文件将使用它来配置服务的基本域。

Traefik 将使用它将 `api.localhost.ospoon.cn` 的流量传输到后端，并将 `dashboard.localhost.ospoon.cn` 的流量传输到前端。

域 `localhost.ospoon.cn` 是一个特殊域，已配置（及其所有子域）指向 `127.0.0.1`。这样你就可以将其用于本地开发。

更新后，再次运行：

```bash
docker compose watch
```

部署时，例如在生产环境中，主 Traefik 在 Docker Compose 文件之外配置。对于本地开发，`docker-compose.override.yml` 中包含一个 Traefik，只是为了让你测试域是否按预期工作，例如使用 `api.localhost.ospoon.cn` 和 `dashboard.localhost.ospoon.cn`。

## Docker Compose 文件和环境变量

有一个主 `docker-compose.yml` 文件，其中包含适用于整个堆栈的所有配置，`docker compose` 会自动使用它。

还有一个 `docker-compose.override.yml` 文件，其中包含用于开发的覆盖配置，例如将源代码挂载为卷。`docker compose` 会自动使用它来在 `docker-compose.yml` 之上应用覆盖。

这些 Docker Compose 文件使用 `.env` 文件，其中包含要作为环境变量注入容器的配置。

它们还使用一些在调用 `docker compose` 命令之前在脚本中设置的环境变量中的其他配置。

更改变量后，请确保重新启动堆栈：

```bash
docker compose watch
```

## .env 文件

`.env` 文件包含所有配置、生成的密钥和密码等。

根据你的工作流程，你可能希望将其从 Git 中排除，例如，如果你的项目是公开的。在这种情况下，你必须确保为 CI 工具设置一种在构建或部署项目时获取它的方法。

一种方法是将每个环境变量添加到你的 CI/CD 系统，并更新 `docker-compose.yml` 文件以读取该特定环境变量，而不是读取 `.env` 文件。

## Pre-commit 和代码检查

我们正在使用一个名为 [pre-commit](https://pre-commit.com/) 的工具进行代码检查和格式化。

安装后，它会在 Git 提交之前运行。这样可以确保代码在提交之前保持一致和格式化。

你可以在项目根目录中找到一个名为 `.pre-commit-config.yaml` 的配置文件。

#### 安装 pre-commit 以自动运行

`pre-commit` 已经是项目依赖项的一部分，但如果你愿意，也可以按照[官方 pre-commit 文档](https://pre-commit.com/)全局安装它。

安装并可用 `pre-commit` 工具后，你需要将其"安装"到本地存储库中，以便它在每次提交之前自动运行。

使用 `uv`，你可以这样做：

```bash
❯ uv run pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

现在，每当你尝试提交时，例如使用：

```bash
git commit
```

...pre-commit 将运行并检查和格式化你将要提交的代码，并要求你在提交之前再次使用 git 添加该代码（暂存它）。

然后你可以再次 `git add` 修改/修复的文件，现在你就可以提交了。

#### 手动运行 pre-commit 钩子

你也可以在所有文件上手动运行 `pre-commit`，你可以使用 `uv` 执行此操作：

```bash
❯ uv run pre-commit run --all-files
check for added large files..............................................Passed
check toml...............................................................Passed
check yaml...............................................................Passed
ruff.....................................................................Passed
ruff-format..............................................................Passed
eslint...................................................................Passed
prettier.................................................................Passed
```

## URL

生产或预演 URL 将使用这些相同的路径，但使用你自己的域。

### 开发 URL

用于本地开发的开发 URL。

前端： http://localhost:5173

后端： http://localhost:8000

自动交互式文档 (Swagger UI)： http://localhost:8000/docs

自动备选文档 (ReDoc)： http://localhost:8000/redoc

Adminer： http://localhost:8080

Traefik UI： http://localhost:8090

MailCatcher： http://localhost:1080

### 配置了 `localhost.ospoon.cn` 的开发 URL

用于本地开发的开发 URL。

前端： http://dashboard.localhost.ospoon.cn

后端： http://api.localhost.ospoon.cn

自动交互式文档 (Swagger UI)： http://api.localhost.ospoon.cn/docs

自动备选文档 (ReDoc)： http://api.localhost.ospoon.cn/redoc

Adminer： http://localhost.ospoon.cn:8080

Traefik UI： http://localhost.ospoon.cn:8090

MailCatcher： http://localhost.ospoon.cn:1080
