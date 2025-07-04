# Makefile for Rustam's Development Environment

.PHONY: help build run connect stop restart logs status clean

# Default target
help:
	@echo "Rustam's Development Environment"
	@echo ""
	@echo "Available commands:"
	@echo "  make build     - Build the Docker image"
	@echo "  make run       - Start the development environment"
	@echo "  make connect   - Connect to running environment"
	@echo "  make stop      - Stop the development environment"
	@echo "  make restart   - Restart the development environment"
	@echo "  make logs      - Show container logs"
	@echo "  make status    - Show container status"
	@echo "  make clean     - Remove containers and images"
	@echo "  make help      - Show this help message"

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
