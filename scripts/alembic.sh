#!/usr/bin/env bash
# Database Management Script - Alembic Operations Interface
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if running in correct directory
if [ ! -f "backend/alembic.ini" ]; then
    echo -e "${RED}❌ Error: Please run this script from the project root directory${NC}"
    exit 1
fi

cd backend

echo -e "${CYAN}🗄️  Database Management Tool (Alembic)${NC}"
echo -e "${CYAN}===============================${NC}"

# Display current database status
show_current_status() {
    echo -e "\n${BLUE}📊 Current Database Status:${NC}"
    echo -e "${YELLOW}Current Version:${NC}"
    uv run alembic current 2>/dev/null || echo "  Not initialized or cannot connect to database"

    echo -e "\n${YELLOW}Migration History:${NC}"
    uv run alembic history --verbose 2>/dev/null | head -10 || echo "  No migration history"
}

# Create new migration file
create_migration() {
    echo -e "\n${GREEN}📝 Create New Database Migration${NC}"
    echo -e "${YELLOW}Please enter migration description (e.g.: Add user avatar field):${NC}"
    read -r migration_message

    if [ -z "$migration_message" ]; then
        echo -e "${RED}❌ Migration description cannot be empty${NC}"
        return 1
    fi

    echo -e "\n${BLUE}Creating migration file...${NC}"
    uv run alembic revision --autogenerate -m "$migration_message"
    echo -e "${GREEN}✅ Migration file created successfully${NC}"
}

# Upgrade database
upgrade_database() {
    echo -e "\n${GREEN}⬆️  Database Upgrade Options${NC}"
    echo "1) Upgrade to latest version (head)"
    echo "2) Upgrade one version (+1)"
    echo "3) Upgrade to specific version"
    echo "0) Return to main menu"

    read -p "Please select: " upgrade_choice

    case $upgrade_choice in
        1)
            echo -e "\n${BLUE}Upgrading to latest version...${NC}"
            uv run alembic upgrade head
            echo -e "${GREEN}✅ Database upgraded to latest version${NC}"
            ;;
        2)
            echo -e "\n${BLUE}Upgrading one version...${NC}"
            uv run alembic upgrade +1
            echo -e "${GREEN}✅ Database upgraded one version${NC}"
            ;;
        3)
            echo -e "\n${YELLOW}Please enter target version ID (e.g.: d98dd8ec85a3):${NC}"
            read -r target_version
            if [ -n "$target_version" ]; then
                echo -e "\n${BLUE}Upgrading to version $target_version...${NC}"
                uv run alembic upgrade "$target_version"
                echo -e "${GREEN}✅ Database upgraded to version $target_version${NC}"
            else
                echo -e "${RED}❌ Version ID cannot be empty${NC}"
            fi
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "${RED}❌ Invalid selection${NC}"
            ;;
    esac
}

# Show specific version details
show_revision_info() {
    echo -e "\n${YELLOW}Please enter version ID to view details:${NC}"
    read -r revision_id

    if [ -n "$revision_id" ]; then
        echo -e "\n${BLUE}Version $revision_id Details:${NC}"
        uv run alembic show "$revision_id"
    else
        echo -e "${RED}❌ Version ID cannot be empty${NC}"
    fi
}

# Main menu
main_menu() {
    while true; do
        show_current_status

        echo -e "\n${CYAN}🔧 Please select an operation:${NC}"
        echo "1) 📝 Create new migration"
        echo "2) ⬆️  Upgrade database"
        echo "3) 🔍 View version details"
        echo "0) 🚪 Exit"

        echo -e "\n${YELLOW}Please enter your choice (0-3):${NC}"
        read -r choice

        case $choice in
            1) create_migration ;;
            2) upgrade_database ;;
            3) show_revision_info ;;
            0)
                echo -e "\n${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "\n${RED}❌ Invalid selection, please enter 0-3${NC}"
                ;;
        esac

        echo -e "\n${CYAN}Press Enter to continue...${NC}"
        read -r
    done
}

# Start main menu
main_menu
