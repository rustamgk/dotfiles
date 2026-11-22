# Makefile for Rustam's Development Environment

.PHONY: help build run connect stop restart logs status clean bootstrap install sync claude-export claude-import claude-pull

# Default target
help:
	@echo "Rustam's Development Environment"
	@echo ""
	@echo "Dotfiles / Local setup:"
	@echo "  make bootstrap  - Bootstrap full environment: macOS / Ubuntu / WSL2 (run once on new machine)"
	@echo "  make install    - Link dotfiles configs to \$$HOME (idempotent)"
	@echo "  make sync       - Sync current configs from \$$HOME into this repo"
	@echo ""
	@echo "Claude Code sessions + memory (gpg-encrypted in secrets/):"
	@echo "  make claude-export            - Fresh encrypted snapshot of ~/.claude into secrets/"
	@echo "  make claude-import            - Restore snapshot into ~/.claude (paths remapped to \$$HOME)"
	@echo "  make claude-pull HOST=u@host  - Copy sessions straight from another machine over ssh"
	@echo ""
	@echo "Docker environment:"
	@echo "  make build     - Build the Docker image"
	@echo "  make run       - Start the development environment"
	@echo "  make connect   - Connect to running environment"
	@echo "  make stop      - Stop the development environment"
	@echo "  make restart   - Restart the development environment"
	@echo "  make logs      - Show container logs"
	@echo "  make status    - Show container status"
	@echo "  make clean     - Remove containers and images"
	@echo "  make help      - Show this help message"

# ---- Dotfiles / Local Setup ----

# Bootstrap a fresh macOS / Ubuntu / WSL2 machine (installs everything)
bootstrap:
	@echo "Bootstrapping environment (auto-detects macOS / Ubuntu / WSL2)..."
	@./scripts/bootstrap.sh

# Link dotfiles to $HOME (idempotent, safe to re-run)
install:
	@./scripts/install.sh

# Sync current live configs back into this repo
sync:
	@echo "Syncing live configs into repo..."
	@cp -v ~/.zshrc configs/.zshrc
	@cp -v ~/.tmux.conf configs/.tmux.conf
	@cp -v ~/.tmux.base.conf configs/.tmux.base.conf
	@cp -v ~/.gitconfig configs/.gitconfig
	@cp -v ~/.config/starship.toml configs/starship.toml
	@cp -rv ~/.config/nvim/. configs/nvim/ 2>/dev/null || true
	@echo "Done! Review changes with: git diff configs/"

# Claude Code sessions + memory (see scripts/claude-sync.sh)
claude-export:
	@./scripts/claude-sync.sh export

claude-import:
	@./scripts/claude-sync.sh import

claude-pull:
	@test -n "$(HOST)" || { echo "Usage: make claude-pull HOST=user@host"; exit 1; }
	@./scripts/claude-sync.sh pull "$(HOST)"

# ---- Docker Environment ----

# Build the Docker image
build:
	@./devenv.sh build

# Start the environment
run:
	@./devenv.sh run

# Connect to the environment
connect:
	@./devenv.sh connect

# Stop the environment
stop:
	@./devenv.sh stop

# Restart the environment
restart:
	@./devenv.sh restart

# Show logs
logs:
	@./devenv.sh logs

# Show status
status:
	@./devenv.sh status

# Clean up Docker resources
clean:
	@echo "Cleaning up Docker resources..."
	@docker-compose down --volumes --remove-orphans 2>/dev/null || true
	@docker-compose -f docker-compose.windows.yml down --volumes --remove-orphans 2>/dev/null || true
	@docker rmi rustam-devenv:latest 2>/dev/null || true
	@docker system prune -f
	@echo "Cleanup complete!"
