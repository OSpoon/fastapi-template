# FastAPI Template

A modern, production-ready FastAPI template with Docker, PostgreSQL, and automated development setup.

## ✨ Features

- **FastAPI** - Modern, fast web framework for building APIs
- **PostgreSQL** - Robust relational database with Alembic migrations
- **Docker** - Containerized development and deployment
- **Ruff** - Lightning-fast Python linter and formatter
- **MyPy** - Static type checking
- **Pre-commit** - Automated code quality checks
- **UV** - Ultra-fast Python package manager
- **VSCode** - Pre-configured development environment

## 🚀 Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Git](https://git-scm.com/downloads)

### One-Command Setup

```bash
# Clone and setup the entire development environment
git clone <your-repo-url>
cd fastapi-template
./scripts/env-setup.sh
```

The setup script will automatically:
- ✅ Install UV package manager
- ✅ Create Python virtual environment
- ✅ Install all dependencies
- ✅ Setup pre-commit hooks
- ✅ Configure VSCode with optimal settings

### Environment Configuration

1. **Edit environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Generate a secure secret key:**
   ```bash
   python -c "import secrets; print(secrets.token_urlsafe(32))"
   ```

### Start Development

```bash
# Start the full stack (API + Database + Admin)
docker compose watch

# Or start individual services
docker compose up -d db        # Database only
docker compose up -d api       # API only
```

### Access Services

- 🌐 **API Documentation**: http://localhost:8000/docs
- 🌐 **API Redoc**: http://localhost:8000/redoc
- 🗄️ **Database Admin**: http://localhost:8080
- 📊 **Health Check**: http://localhost:8000/health

## 🛠️ Development

### Code Quality

All code quality tools are pre-configured and automated:

```bash
# Format code
cd backend && uv run ruff format .

# Check code quality
cd backend && uv run ruff check . --fix

# Type checking
cd backend && uv run mypy app

# Run all checks (pre-commit)
uv run pre-commit run --all-files
```

### Testing

```bash
# Run tests
./scripts/test.sh

# Run with coverage
cd backend
uv run pytest --cov=app --cov-report=html
```

### Database Management

```bash
# Create migration
cd backend
uv run alembic revision --autogenerate -m "Description"

# Apply migrations
uv run alembic upgrade head

# Reset database (development only)
docker compose down -v
docker compose up -d db
```

## 📁 Project Structure

```
fastapi-template/
├── backend/               # FastAPI application
│   ├── app/               # Application code
│   │   ├── api/           # API routes
│   │   ├── core/          # Configuration & utilities
│   │   ├── crud/          # Database operations
│   │   ├── models/        # SQLAlchemy models
│   │   └── schemas/       # Pydantic models
│   ├── alembic/           # Database migrations
│   ├── scripts/           # Development scripts
│   └── tests/             # Test cases
├── scripts/               # Project-level scripts
├── docker-compose.yml     # Docker services
└── README.md
```

## 🔧 Manual Setup (Alternative)

If you prefer manual setup or the automatic script doesn't work:

<details>
<summary>Click to expand manual setup instructions</summary>

### 1. Install Dependencies

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Setup backend
cd backend
uv sync
```

### 2. Setup Pre-commit

```bash
uv run pre-commit install
```

### 3. Configure VSCode

Install recommended extensions:
- Python
- Pylance
- Ruff
- MyPy Type Checker
- Docker
- REST Client

### 4. Environment Variables

```bash
cp .env.example .env
# Edit .env file with your settings
```

</details>

## 🐳 Docker Commands

```bash
# Development with auto-reload
docker compose watch

# Production build
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# View logs
docker compose logs -f api

# Clean up
docker compose down -v
```

## 🤝 Contributing

1. **Fork the repository**
2. **Run the setup script**: `./scripts/env-setup.sh`
3. **Create your feature branch**: `git checkout -b feature/amazing-feature`
4. **Make your changes** - pre-commit hooks will automatically check your code
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you encounter any issues:

1. **Check the logs**: `docker compose logs -f`
2. **Verify environment**: `./scripts/env-setup.sh` (safe to run multiple times)
3. **Reset environment**: `docker compose down -v && ./scripts/env-setup.sh`

---

**Happy coding! 🚀**

## 🙏 Acknowledgments

This project is based on the excellent [FastAPI Full Stack Template](https://github.com/fastapi/full-stack-fastapi-template) by the FastAPI team. We've adapted and streamlined it with:

- **Simplified setup** - One-command environment initialization
- **Enhanced developer experience** - Pre-configured VSCode and automated workflows
- **Streamlined architecture** - Focused on backend API development

### Original Template Features Retained:
- 🔐 JWT authentication system
- 🗄️ PostgreSQL with SQLAlchemy 2.0
- 📋 Alembic database migrations
- 🐳 Docker containerization
- 🧪 Pytest test framework
- 📚 Interactive API documentation

### Key Differences from Original:
- **Removed frontend** - Backend-focused template
- **Automated setup** - Single script for complete environment setup

## 📖 Related Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Original Full Stack Template](https://github.com/fastapi/full-stack-fastapi-template)
- [UV Package Manager](https://github.com/astral-sh/uv)
- [Ruff Linter](https://github.com/astral-sh/ruff)

---

**Built with ❤️ based on FastAPI Full Stack Template**
