# FastAPI Template

## 技术栈和特性

- ⚡ [**FastAPI**](https://fastapi.ospoon.cn) 用于 Python 后端 API。
    - 🧰 [SQLModel](https://sqlmodel.ospoon.cn) 用于 Python SQL 数据库交互 (ORM)。
    - 🔍 [Pydantic](https://docs.pydantic.dev)，FastAPI 使用它进行数据验证和设置管理。
    - 💾 [PostgreSQL](https://www.postgresql.org) 作为 SQL 数据库。
- 🐋 [Docker Compose](https://www.docker.com) 用于开发和生产。
- 🔒 默认安全密码哈希。
- 🔑 JWT (JSON Web Token) 认证。
- 📫 基于邮件的密码恢复。
- ✅ 使用 [Pytest](https://pytest.org) 进行测试。
- 📞 [Traefik](https://traefik.io) 作为反向代理/负载均衡器。
- 🚢 使用 Docker Compose 的部署说明，包括如何设置前端 Traefik 代理以处理自动 HTTPS 证书。
- 🏭 基于 GitHub Actions 的 CI (持续集成) 和 CD (持续部署)。

## 如何使用

你可以**直接 fork 或克隆**这个仓库并按原样使用。

### 如何使用私有仓库

如果你想拥有一个私有仓库，GitHub 不允许你简单地 fork 它，因为它不允许更改 fork 的可见性。

但是你可以这样做：

- 创建一个新的 GitHub 仓库，例如 `my-progect`。
- 手动克隆此仓库，并使用你想要使用的项目名称设置名称，例如 `my-project`：

```bash
git clone https://github.com/OSpoon/fastapi-template.git my-project
```

- 进入新目录：

```bash
cd my-project
```

- 将新的 origin 设置为你的新仓库，从 GitHub 界面复制它，例如：

```bash
git remote set-url origin https://github.com/<user-name>/my-project.git
```

- 将代码推送到你的新仓库：

```bash
git push -u origin main
```

### 配置

然后，你可以更新 `.env` 文件中的配置以自定义你的配置。

在部署之前，请确保至少更改以下值：

- `SECRET_KEY`
- `FIRST_SUPERUSER_PASSWORD`
- `POSTGRES_PASSWORD`

你可以（并且应该）将这些作为来自机密的环境变量传递。

阅读 [deployment.md](./deployment.md) 文档以获取更多详细信息。

### 生成密钥

`.env` 文件中的某些环境变量的默认值为 `changethis`。

你必须使用密钥更改它们，要生成密钥，可以运行以下命令：

```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

复制内容并将其用作密码/密钥。然后再次运行以生成另一个安全密钥。

## 后端开发

后端文档：[backend/README.md](./backend/README.md)。

## 部署

部署文档：[deployment.md](./deployment.md)。

## 开发

常规开发文档：[development.md](./development.md)。

这包括使用 Docker Compose、自定义本地域、`.env` 配置等。

## 许可证

**FastAPI Template** 根据 MIT 许可证的条款进行许可。
