#!/bin/bash

# Universal build and run script for Rustam's Development Environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version 2>/dev/null; then
            echo "wsl2"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Build the Docker image
build_image() {
    print_status "Building development environment Docker image..."
    docker build -t rustam-devenv:latest .
    print_success "Docker image built successfully!"
}

# Run the container
run_container() {
    local platform=$1
    local compose_file="docker-compose.yml"
    
    if [[ "$platform" == "wsl2" ]]; then
        compose_file="docker-compose.windows.yml"
        print_status "Using Windows WSL2 configuration..."
    else
        print_status "Using Linux/macOS configuration..."
    fi
    
    # Check if container is already running
    if docker ps | grep -q rustam-devenv; then
        print_warning "Container is already running. Stopping it first..."
        docker-compose -f "$compose_file" down
    fi
    
    print_status "Starting development environment..."
    docker-compose -f "$compose_file" up -d
    
    print_success "Development environment is running!"
    print_status "Connect with: docker exec -it rustam-devenv zsh"
}

# Connect to running container
connect_container() {
    if ! docker ps | grep -q rustam-devenv; then
        print_error "Container is not running. Start it first with: $0 run"
        exit 1
    fi
    
    print_status "Connecting to development environment..."
    docker exec -it rustam-devenv zsh
}

# Stop the container
stop_container() {
    local platform=$1
    local compose_file="docker-compose.yml"
    
    if [[ "$platform" == "wsl2" ]]; then
        compose_file="docker-compose.windows.yml"
    fi
    
    print_status "Stopping development environment..."
    docker-compose -f "$compose_file" down
    print_success "Development environment stopped!"
}

# Show help
show_help() {
    echo "Rustam's Development Environment Manager"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build      Build the Docker image"
    echo "  run        Start the development environment"
    echo "  connect    Connect to running environment"
    echo "  stop       Stop the development environment"
    echo "  restart    Restart the development environment"
    echo "  logs       Show container logs"
    echo "  status     Show container status"
    echo "  help       Show this help message"
    echo ""
    echo "Platform Support:"
    echo "  - macOS: Uses ~/workspace and ~/helm"
    echo "  - Linux: Uses ~/workspace and ~/helm"
    echo "  - Windows WSL2: Uses /mnt/c/Source/workspace and /mnt/c/Source/helm"
}

# Show container logs
show_logs() {
    local platform=$1
    local compose_file="docker-compose.yml"
    
    if [[ "$platform" == "wsl2" ]]; then
        compose_file="docker-compose.windows.yml"
    fi
    
    docker-compose -f "$compose_file" logs -f
}

# Show container status
show_status() {
    echo "=== Docker Images ==="
    docker images | grep rustam-devenv || echo "No rustam-devenv image found"
    echo ""
    echo "=== Running Containers ==="
    docker ps | grep rustam-devenv || echo "No rustam-devenv container running"
    echo ""
    echo "=== All Containers ==="
    docker ps -a | grep rustam-devenv || echo "No rustam-devenv containers found"
}

# Main script logic
main() {
    local command=${1:-help}
    local platform=$(detect_platform)
    
    print_status "Detected platform: $platform"
    
    case $command in
        "build")
            build_image
            ;;
        "run")
            build_image
            run_container "$platform"
            ;;
        "connect"|"exec"|"shell")
            connect_container
            ;;
        "stop")
            stop_container "$platform"
            ;;
        "restart")
            stop_container "$platform"
            sleep 2
            run_container "$platform"
            ;;
        "logs")
            show_logs "$platform"
            ;;
        "status")
            show_status
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed or not in PATH"
    exit 1
fi

# Run main function
main "$@"
