#!/bin/bash

# Universal build and run script for Rustam's Development Environment with Profile Support

set -e

# Default profile
PROFILE=${1:-personal}
COMMAND=${2:-help}

# Validate profile
validate_profile() {
    case $PROFILE in
        "personal"|"work_sarna"|"work_sdui")
            ;;
        *)
            print_error "Invalid profile: $PROFILE"
            echo "Valid profiles: personal, work_sarna, work_sdui"
            echo "Usage: $0 [PROFILE] [COMMAND]"
            exit 1
            ;;
    esac
}

# Get profile-specific configuration
get_profile_config() {
    case $PROFILE in
        "personal")
            CONTAINER_NAME="rustam-devenv-personal"
            IMAGE_NAME="rustam-devenv:personal"
            DOCKERHUB_IMAGE="rustamgk/dotfiles:latest"
            WORKSPACE_PATH="$HOME/workspace"
            HELM_PATH="$HOME/helm"
            COMPOSE_FILE="docker-compose.yml"
            DOCKERFILE="Dockerfile"
            ;;
        "work_sarna")
            CONTAINER_NAME="rustam-devenv-sarna"
            IMAGE_NAME="rustam-devenv:sarna"
            DOCKERHUB_IMAGE="rustamgk/dotfiles:sarna"
            WORKSPACE_PATH="$HOME/workspace/sarna"
            HELM_PATH="$HOME/helm/sarna"
            COMPOSE_FILE="docker-compose.sarna.yml"
            DOCKERFILE="Dockerfile.sarna"
            ;;
        "work_sdui")
            CONTAINER_NAME="rustam-devenv-sdui"
            IMAGE_NAME="rustam-devenv:sdui"
            DOCKERHUB_IMAGE="rustamgk/dotfiles:sdui"
            WORKSPACE_PATH="$HOME/workspace/sdui"
            HELM_PATH="$HOME/helm/sdui"
            COMPOSE_FILE="docker-compose.sdui.yml"
            DOCKERFILE="Dockerfile.sdui"
            ;;
    esac
    
    # Export for docker-compose
    export CONTAINER_NAME
    export IMAGE_NAME
    export WORKSPACE_PATH
    export HELM_PATH
}

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

# Pull pre-built image from Docker Hub
pull_image() {
    print_status "Pulling pre-built Docker image from Docker Hub: $DOCKERHUB_IMAGE"
    
    if docker pull "$DOCKERHUB_IMAGE"; then
        # Tag the pulled image with local name for compatibility
        docker tag "$DOCKERHUB_IMAGE" "$IMAGE_NAME"
        print_success "Docker image '$DOCKERHUB_IMAGE' pulled and tagged as '$IMAGE_NAME' successfully!"
        return 0
    else
        print_warning "Failed to pull image from Docker Hub. Will build locally instead."
        return 1
    fi
}

# Build the Docker image locally
build_image() {
    print_status "Building development environment Docker image for profile: $CONTAINER_NAME"
    
    # Check if custom Dockerfile exists, otherwise use default
    if [[ ! -f "$DOCKERFILE" ]]; then
        print_warning "Custom Dockerfile '$DOCKERFILE' not found, using default Dockerfile"
        DOCKERFILE="Dockerfile"
    fi
    
    docker build -f "$DOCKERFILE" -t "$IMAGE_NAME" .
    print_success "Docker image '$IMAGE_NAME' built successfully!"
}

# Get or build the Docker image (try pull first, fallback to build)
get_image() {
    # Check if image already exists locally
    if docker images | grep -q "$IMAGE_NAME"; then
        print_status "Local image '$IMAGE_NAME' already exists. Use 'rebuild' to force rebuild or 'pull' to update."
        return 0
    fi
    
    # Try to pull from Docker Hub first
    if pull_image; then
        return 0
    else
        # Fallback to local build
        build_image
        return $?
    fi
}

# Run the container
run_container() {
    local platform=$1
    
    # Check if custom compose file exists, otherwise use default
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        print_warning "Custom compose file '$COMPOSE_FILE' not found, using default docker-compose.yml"
        COMPOSE_FILE="docker-compose.yml"
    fi
    
    print_status "Using configuration: $COMPOSE_FILE"
    
    # Check if container is already running
    if docker ps | grep -q "$CONTAINER_NAME"; then
        print_warning "Container $CONTAINER_NAME is already running. Stopping it first..."
        docker-compose -f "$COMPOSE_FILE" down
    fi
    
    print_status "Starting development environment: $CONTAINER_NAME..."
    docker-compose -f "$COMPOSE_FILE" up -d
    
    print_success "Development environment '$CONTAINER_NAME' is running!"
    print_status "Connect with: docker exec -it $CONTAINER_NAME zsh"
    print_status "Or use: $0 $PROFILE connect"
}

# Connect to running container
connect_container() {
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        print_error "Container '$CONTAINER_NAME' is not running. Start it first with: $0 $PROFILE run"
        exit 1
    fi
    
    print_status "Connecting to development environment: $CONTAINER_NAME..."
    docker exec -it "$CONTAINER_NAME" zsh
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
    echo "Usage: $0 [PROFILE] [COMMAND]"
    echo ""
    echo "Profiles:"
    echo "  personal     Personal development environment (default)"
    echo "  work_sarna   Work environment for Sarna project"
    echo "  work_sdui    Work environment for SDUI project"
    echo ""
    echo "Commands:"
    echo "  run        Pull/build image (if needed) and start container"
    echo "  pull       Pull pre-built image from Docker Hub"
    echo "  build      Build Docker image locally"
    echo "  rebuild    Force rebuild Docker image locally"
    echo "  connect    Connect to running environment"
    echo "  stop       Stop the development environment"
    echo "  restart    Restart the development environment"
    echo "  logs       Show container logs"
    echo "  status     Show container status"
    echo "  help       Show this help message"
    echo ""
    echo "Profile Configurations:"
    echo "  personal     → ~/workspace & ~/helm"
    echo "  work_sarna   → ~/workspace/sarna & ~/helm/sarna"
    echo "  work_sdui    → ~/workspace/sdui & ~/helm/sdui"
    echo ""
    echo "Platform Support:"
    echo "  - macOS: Uses ~/workspace and ~/helm"
    echo "  - Linux: Uses ~/workspace and ~/helm"
    echo "  - Windows WSL2: Uses /mnt/c/Source/workspace and /mnt/c/Source/helm"
    echo ""
    echo "Examples:"
    echo "  $0 personal run       # Start personal environment"
    echo "  $0 work_sarna connect # Connect to Sarna environment"
    echo "  $0 work_sdui stop     # Stop SDUI environment"
    echo "  $0 status             # Show all containers"
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
    # Validate profile and get config
    validate_profile
    get_profile_config
    
    local platform
    platform=$(detect_platform)
    
    print_status "Detected platform: $platform"
    print_status "Using profile: $PROFILE"
    
    case $COMMAND in
        "build")
            build_image
            ;;
        "pull")
            pull_image
            ;;
        "rebuild")
            build_image
            ;;
        "run")
            get_image
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
            get_image
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
            print_error "Unknown command: $COMMAND"
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
main
