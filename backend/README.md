# FastAPI 项目 - 后端

## 要求

* [Docker](https://www.docker.com/)。
* [uv](https://docs.astral.sh/uv/) 用于 Python 包和环境管理。

## Docker Compose

按照 [../development.md](../development.md) 中的指南使用 Docker Compose 启动本地开发环境。

## 一般工作流程

默认情况下，依赖项使用 [uv](https://docs.astral.sh/uv/) 管理，请前往该页面并安装它。

从 `./backend/` 目录，你可以安装所有依赖项：

```console
$ uv sync
```

然后你可以激活虚拟环境：

```console
$ source .venv/bin/activate
```

确保你的编辑器使用正确的 Python 虚拟环境，解释器位于 `backend/.venv/bin/python`。

在 `./backend/app/models.py` 中修改或添加用于数据和 SQL 表的 SQLModel 模型，在 `./backend/app/api/` 中添加 API 端点，在 `./backend/app/crud.py` 中添加 CRUD（创建、读取、更新、删除）工具。

## VS Code

已经有配置可以通过 VS Code 调试器运行后端，这样你就可以使用断点、暂停和探索变量等功能。

设置也已配置，使你可以通过 VS Code Python 测试选项卡运行测试。

## Docker Compose 覆盖

在开发过程中，你可以在 `docker-compose.override.yml` 文件中更改 Docker Compose 设置，这些设置只会影响本地开发环境。

对该文件的更改只影响本地开发环境，不影响生产环境。因此，你可以添加有助于开发工作流程的"临时"更改。

例如，包含后端代码的目录在 Docker 容器中同步，将你更改的代码实时复制到容器内的目录中。这允许你立即测试更改，而无需重新构建 Docker 镜像。这应该只在开发过程中进行，对于生产环境，你应该使用最新版本的后端代码构建 Docker 镜像。但在开发过程中，它允许你非常快速地迭代。

还有一个命令覆盖，运行 `fastapi run --reload` 而不是默认的 `fastapi run`。它启动一个单一服务器进程（而不是像生产环境那样的多个进程），并在代码更改时重新加载进程。请注意，如果你有语法错误并保存 Python 文件，它会中断并退出，容器会停止。之后，你可以通过修复错误并再次运行来重启容器：

```console
$ docker compose watch
```

还有一个注释掉的 `command` 覆盖，你可以取消注释并注释掉默认的。它使后端容器运行一个"什么都不做"的进程，但保持容器活动。这允许你进入正在运行的容器并在其中执行命令，例如测试已安装依赖项的 Python 解释器，或启动检测到更改时重新加载的开发服务器。

要使用 `bash` 会话进入容器，你可以启动堆栈：

```console
$ docker compose watch
```

然后在另一个终端中，`exec` 进入正在运行的容器：

```console
$ docker compose exec backend bash
```

你应该看到如下输出：

```console
root@7f2607af31c3:/app#
```

这意味着你在容器内的 `bash` 会话中，作为 `root` 用户，在 `/app` 目录下，该目录内有另一个名为"app"的目录，这就是你的代码在容器内的位置：`/app/app`。

在那里你可以使用 `fastapi run --reload` 命令运行调试实时重新加载服务器。

```console
$ fastapi run --reload app/main.py
```

...它看起来像：

```console
root@7f2607af31c3:/app# fastapi run --reload app/main.py
```

然后按回车。这会运行实时重新加载服务器，当检测到代码更改时会自动重新加载。

但是，如果它没有检测到更改但有语法错误，它只会因错误而停止。但由于容器仍然活动并且你在 Bash 会话中，你可以在修复错误后快速重启它，运行相同的命令（"向上箭头"和"回车"）。

...这个先前的细节使得让容器保持活动状态什么都不做，然后在 Bash 会话中让它运行实时重新加载服务器变得有用。

## 后端测试

要测试后端，运行：

```console
$ bash ./scripts/test.sh
```

测试使用 Pytest 运行，在 `./backend/app/tests/` 中修改和添加测试。

如果你使用 GitHub Actions，测试将自动运行。

### 测试运行堆栈

如果你的堆栈已经启动，你只想运行测试，可以使用：

```bash
docker compose exec backend bash scripts/tests-start.sh
```

该 `/app/scripts/tests-start.sh` 脚本在确保堆栈的其余部分正在运行后只调用 `pytest`。如果你需要向 `pytest` 传递额外参数，可以将它们传递给该命令，它们将被转发。

例如，在第一个错误时停止：

```bash
docker compose exec backend bash scripts/tests-start.sh -x
```

### 测试覆盖率

运行测试时，会生成一个文件 `htmlcov/index.html`，你可以在浏览器中打开它以查看测试覆盖率。

## 迁移

由于在本地开发期间你的应用目录作为卷挂载在容器内，你也可以在容器内使用 `alembic` 命令运行迁移，迁移代码将在你的应用目录中（而不是仅在容器内）。因此你可以将其添加到你的 git 仓库中。

确保每次更改模型时都创建模型的"修订"并使用该修订"升级"数据库。因为这是更新数据库中表的操作。否则，你的应用程序会出错。

* 在后端容器中启动交互式会话：

```console
$ docker compose exec backend bash
```

* Alembic 已配置为从 `./backend/app/models.py` 导入你的 SQLModel 模型。

* 更改模型后（例如，添加列），在容器内创建修订，例如：

```console
$ alembic revision --autogenerate -m "Add column last_name to User model"
```

* 将 alembic 目录中生成的文件提交到 git 仓库。

* 创建修订后，在数据库中运行迁移（这是实际更改数据库的操作）：

```console
$ alembic upgrade head
```

如果你根本不想使用迁移，请取消注释 `./backend/app/core/db.py` 文件中以下结尾的行：

```python
SQLModel.metadata.create_all(engine)
```

并注释 `scripts/prestart.sh` 文件中包含以下内容的行：

```console
$ alembic upgrade head
```

如果你不想从默认模型开始并想从一开始就删除/修改它们，没有任何先前的修订，你可以删除 `./backend/app/alembic/versions/` 下的修订文件（`.py` Python 文件）。然后如上所述创建第一次迁移。

## 邮件模板

邮件模板在 `./backend/app/email-templates/` 中。这里有两个目录：`build` 和 `src`。`src` 目录包含用于构建最终邮件模板的源文件。`build` 目录包含应用程序使用的最终邮件模板。

在继续之前，确保你在 VS Code 中安装了 [MJML 扩展](https://marketplace.visualstudio.com/items?itemName=attilabuti.vscode-mjml)。

安装 MJML 扩展后，你可以在 `src` 目录中创建新的邮件模板。创建新的邮件模板并在编辑器中打开 `.mjml` 文件后，使用 `Ctrl+Shift+P` 打开命令面板并搜索 `MJML: Export to HTML`。这将把 `.mjml` 文件转换为 `.html` 文件，现在你可以将其保存在 build 目录中。
