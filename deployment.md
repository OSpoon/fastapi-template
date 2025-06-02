# FastAPI 项目 - 部署

你可以使用 Docker Compose 将项目部署到远程服务器。

此项目期望你有一个 Traefik 代理来处理与外部世界的通信和 HTTPS 证书。

你可以使用 CI/CD（持续集成和持续部署）系统进行自动部署，已经有配置可以通过 GitHub Actions 来实现。

但是你必须先配置一些东西。🤓

## 准备工作

* 准备一台远程服务器并确保可用。
* 配置你域名的 DNS 记录指向你刚创建的服务器 IP。
* 为你的域名配置通配符子域，这样你可以为不同的服务使用多个子域，例如 `*.fastapi-project.example.com`。这对于访问不同组件很有用，如 `dashboard.fastapi-project.example.com`、`api.fastapi-project.example.com`、`traefik.fastapi-project.example.com`、`adminer.fastapi-project.example.com` 等。还有用于 `staging` 环境，如 `dashboard.staging.fastapi-project.example.com`、`adminer.staging.fastapi-project.example.com` 等。
* 在远程服务器上安装和配置 [Docker](https://docs.docker.com/engine/install/)（Docker Engine，不是 Docker Desktop）。

## 公共 Traefik

我们需要一个 Traefik 代理来处理传入连接和 HTTPS 证书。

你只需要执行下面的步骤一次。

### Traefik Docker Compose

* 创建一个远程目录来存储你的 Traefik Docker Compose 文件：

```bash
mkdir -p /root/code/traefik-public/
```

将 Traefik Docker Compose 文件复制到你的服务器。你可以在本地终端中运行 `rsync` 命令：

```bash
rsync -a docker-compose.traefik.yml root@your-server.example.com:/root/code/traefik-public/
```

### Traefik 公共网络

这个 Traefik 期望有一个名为 `traefik-public` 的 Docker "公共网络" 来与你的堆栈通信。

这样，将有一个单独的公共 Traefik 代理来处理与外部世界的通信（HTTP 和 HTTPS），然后在其后面，你可以有一个或多个具有不同域名的堆栈，即使它们在同一台服务器上。

要创建名为 `traefik-public` 的 Docker "公共网络"，在你的远程服务器上运行以下命令：

```bash
docker network create traefik-public
```

### Traefik 环境变量

Traefik Docker Compose 文件期望在启动之前在你的终端中设置一些环境变量。你可以在远程服务器上运行以下命令来完成。

* 创建 HTTP 基本认证的用户名，例如：

```bash
export USERNAME=admin
```

* 创建包含 HTTP 基本认证密码的环境变量，例如：

```bash
export PASSWORD=changethis
```

* 使用 openssl 生成 HTTP 基本认证密码的"哈希"版本并将其存储在环境变量中：

```bash
export HASHED_PASSWORD=$(openssl passwd -apr1 $PASSWORD)
```

要验证哈希密码是否正确，你可以打印它：

```bash
echo $HASHED_PASSWORD
```

* 创建包含你服务器域名的环境变量，例如：

```bash
export DOMAIN=fastapi-project.example.com
```

* 创建包含 Let's Encrypt 邮箱的环境变量，例如：

```bash
export EMAIL=admin@example.com
```

**注意**：你需要设置一个不同的邮箱，`@example.com` 邮箱是无效的。

### 启动 Traefik Docker Compose

在远程服务器上进入你复制 Traefik Docker Compose 文件的目录：

```bash
cd /root/code/traefik-public/
```

现在设置了环境变量并且 `docker-compose.traefik.yml` 就位后，你可以运行以下命令启动 Traefik Docker Compose：

```bash
docker compose -f docker-compose.traefik.yml up -d
```

## 部署 FastAPI 项目

现在你有了 Traefik，可以使用 Docker Compose 部署你的 FastAPI 项目。

**注意**：你可能想跳到关于使用 GitHub Actions 进行持续部署的部分。

## 环境变量

你需要首先设置一些环境变量。

设置 `ENVIRONMENT`，默认为 `local`（用于开发），但在部署到服务器时你会放置类似 `staging` 或 `production` 的值：

```bash
export ENVIRONMENT=production
```

设置 `DOMAIN`，默认为 `localhost`（用于开发），但在部署时你会使用自己的域名，例如：

```bash
export DOMAIN=fastapi-project.example.com
```

你可以设置多个变量，如：

* `PROJECT_NAME`：项目名称，在 API 文档和邮件中使用。
* `STACK_NAME`：用于 Docker Compose 标签和项目名称的堆栈名称，这对于 `staging`、`production` 等应该不同。你可以使用相同域名将点替换为破折号，例如 `fastapi-project-example-com` 和 `staging-fastapi-project-example-com`。
* `BACKEND_CORS_ORIGINS`：以逗号分隔的允许的 CORS 源列表。
* `SECRET_KEY`：FastAPI 项目的密钥，用于签名令牌。
* `FIRST_SUPERUSER`：第一个超级用户的邮箱，这个超级用户可以创建新用户。
* `FIRST_SUPERUSER_PASSWORD`：第一个超级用户的密码。
* `SMTP_HOST`：发送邮件的 SMTP 服务器主机，这来自你的邮件提供商（例如 Mailgun、Sparkpost、Sendgrid 等）。
* `SMTP_USER`：发送邮件的 SMTP 服务器用户。
* `SMTP_PASSWORD`：发送邮件的 SMTP 服务器密码。
* `EMAILS_FROM_EMAIL`：发送邮件的邮箱账户。
* `POSTGRES_SERVER`：PostgreSQL 服务器的主机名。你可以保留由同一 Docker Compose 提供的默认值 `db`。除非你使用第三方提供商，否则通常不需要更改。
* `POSTGRES_PORT`：PostgreSQL 服务器的端口。你可以保留默认值。除非你使用第三方提供商，否则通常不需要更改。
* `POSTGRES_PASSWORD`：Postgres 密码。
* `POSTGRES_USER`：Postgres 用户，你可以保留默认值。
* `POSTGRES_DB`：此应用程序使用的数据库名称。你可以保留默认值 `app`。
* `SENTRY_DSN`：Sentry 的 DSN，如果你正在使用它。

## GitHub Actions 环境变量

有一些仅由 GitHub Actions 使用的环境变量，你可以配置：

* `LATEST_CHANGES`：由 GitHub Action [latest-changes](https://github.com/tiangolo/latest-changes) 使用，根据合并的 PR 自动添加发布说明。这是一个个人访问令牌，详细信息请阅读文档。
* `SMOKESHOW_AUTH_KEY`：用于处理和发布使用 [Smokeshow](https://github.com/samuelcolvin/smokeshow) 的代码覆盖率，按照他们的说明创建（免费的）Smokeshow 密钥。

### 生成密钥

`.env` 文件中的一些环境变量的默认值为 `changethis`。

你必须用密钥替换它们，要生成密钥，你可以运行以下命令：

```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

复制内容并将其用作密码/密钥。再次运行以生成另一个安全密钥。

### 使用 Docker Compose 部署

设置好环境变量后，你可以使用 Docker Compose 部署：

```bash
docker compose -f docker-compose.yml up -d
```

对于生产环境，你不希望有 `docker-compose.override.yml` 中的覆盖，这就是为什么我们明确指定 `docker-compose.yml` 作为要使用的文件。

## 持续部署（CD）

你可以使用 GitHub Actions 自动部署你的项目。😎

你可以有多个环境部署。

已经配置了两个环境：`staging` 和 `production`。🚀

### 安装 GitHub Actions Runner

* 在你的远程服务器上，为你的 GitHub Actions 创建一个用户：

```bash
sudo adduser github
```

* 将 Docker 权限添加到 `github` 用户：

```bash
sudo usermod -aG docker github
```

* 临时切换到 `github` 用户：

```bash
sudo su - github
```

* 进入 `github` 用户的主目录：

```bash
cd
```

* [按照官方指南安装 GitHub Action 自托管运行器](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository)。

* 当询问标签时，为环境添加一个标签，例如 `production`。你也可以稍后添加标签。

安装后，指南会告诉你运行一个命令来启动运行器。但是，一旦你终止该进程或如果你与服务器的本地连接丢失，它就会停止。

为了确保它在启动时运行并继续运行，你可以将其安装为服务。要做到这一点，退出 `github` 用户并回到 `root` 用户：

```bash
exit
```

做完后，你将再次使用之前的用户。你将在之前的目录中，属于该用户。

在能够进入 `github` 用户目录之前，你需要成为 `root` 用户（你可能已经是了）：

```bash
sudo su
```

* 作为 `root` 用户，进入 `github` 用户主目录内的 `actions-runner` 目录：

```bash
cd /home/github/actions-runner
```

* 使用用户 `github` 将自托管运行器安装为服务：

```bash
./svc.sh install github
```

* 启动服务：

```bash
./svc.sh start
```

* 检查服务状态：

```bash
./svc.sh status
```

你可以在官方指南中阅读更多信息：[将自托管运行器应用程序配置为服务](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service)。

### 设置密钥

在你的仓库中，为你需要的环境变量配置密钥，与上面描述的相同，包括 `SECRET_KEY` 等。按照 [GitHub 设置仓库密钥的官方指南](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository)。

当前的 GitHub Actions 工作流期望这些密钥：

* `DOMAIN_PRODUCTION`
* `DOMAIN_STAGING`
* `STACK_NAME_PRODUCTION`
* `STACK_NAME_STAGING`
* `EMAILS_FROM_EMAIL`
* `FIRST_SUPERUSER`
* `FIRST_SUPERUSER_PASSWORD`
* `POSTGRES_PASSWORD`
* `SECRET_KEY`
* `LATEST_CHANGES`
* `SMOKESHOW_AUTH_KEY`

## GitHub Action 部署工作流

在 `.github/workflows` 目录中已经有配置好的 GitHub Action 工作流用于部署到环境（带有标签的 GitHub Actions 运行器）：

* `staging`：推送（或合并）到 `main` 分支后。
* `production`：发布版本后。

如果你需要添加额外的环境，你可以使用这些作为起点。

## URL

将 `fastapi-project.example.com` 替换为你的域名。

### 主要 Traefik 仪表板

Traefik UI：`https://traefik.fastapi-project.example.com`

### 生产环境

前端：`https://dashboard.fastapi-project.example.com`

后端 API 文档：`https://api.fastapi-project.example.com/docs`

后端 API 基础 URL：`https://api.fastapi-project.example.com`

Adminer：`https://adminer.fastapi-project.example.com`

### 预演环境

前端：`https://dashboard.staging.fastapi-project.example.com`

后端 API 文档：`https://api.staging.fastapi-project.example.com/docs`

后端 API 基础 URL：`https://api.staging.fastapi-project.example.com`

Adminer：`https://adminer.staging.fastapi-project.example.com`
