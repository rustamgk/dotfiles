# Rustam's Development Environment Manager for Windows
# PowerShell script for Windows 11 with Profile Support

param(
    [Parameter(Position=0)]
    [string]$Profile = "personal",
    [Parameter(Position=1)]
    [string]$Command = "help"
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Validate profile
function Test-Profile {
    param([string]$Profile)
    
    $validProfiles = @("personal", "work_sarna", "work_sdui")
    if ($Profile -notin $validProfiles) {
        Write-Error "Invalid profile: $Profile"
        Write-Host "Valid profiles: $($validProfiles -join ', ')" -ForegroundColor $Yellow
        exit 1
    }
}

# Get profile-specific configuration
function Get-ProfileConfig {
    param([string]$Profile)
    
    $config = @{}
    
    switch ($Profile) {
        "personal" {
            $config.ContainerName = "rustam-devenv-personal"
            $config.ImageName = "rustam-devenv:personal"
            $config.DockerHubImage = "rustamgk/dotfiles:latest"
            $config.WorkspacePath = "C:\workspace"
            $config.HelmPath = "C:\helm"
            $config.ComposeFile = "docker-compose.yml"
            $config.Dockerfile = "Dockerfile"
        }
        "work_sarna" {
            $config.ContainerName = "rustam-devenv-sarna"
            $config.ImageName = "rustam-devenv:sarna"
            $config.DockerHubImage = "rustamgk/dotfiles:sarna"
            $config.WorkspacePath = "C:\workspace\sarna"
            $config.HelmPath = "C:\helm\sarna"
            $config.ComposeFile = "docker-compose.sarna.yml"
            $config.Dockerfile = "Dockerfile.sarna"
        }
        "work_sdui" {
            $config.ContainerName = "rustam-devenv-sdui"
            $config.ImageName = "rustam-devenv:sdui"
            $config.DockerHubImage = "rustamgk/dotfiles:sdui"
            $config.WorkspacePath = "C:\workspace\sdui"
            $config.HelmPath = "C:\helm\sdui"
            $config.ComposeFile = "docker-compose.sdui.yml"
            $config.Dockerfile = "Dockerfile.sdui"
        }
    }
    
    return $config
}

# Detect platform
function Get-Platform {
    if ($env:OS -eq "Windows_NT") {
        return "windows"
    }
    return "unknown"
}

# Pull pre-built image from Docker Hub
function Pull-Image {
    param([hashtable]$Config)
    
    Write-Status "Pulling pre-built Docker image from Docker Hub: $($Config.DockerHubImage)"
    
    $pullResult = docker pull $Config.DockerHubImage
    if ($LASTEXITCODE -eq 0) {
        # Tag the pulled image with local name for compatibility
        docker tag $Config.DockerHubImage $Config.ImageName
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker image '$($Config.DockerHubImage)' pulled and tagged as '$($Config.ImageName)' successfully!"
            return $true
        }
    }
    
    Write-Warning "Failed to pull image from Docker Hub. Will build locally instead."
    return $false
}

# Build the Docker image locally
function Build-Image {
    param([hashtable]$Config)
    
    Write-Status "Building development environment Docker image for profile: $($Config.ContainerName)"
    
    # Check if custom Dockerfile exists, otherwise use default
    $dockerFile = $Config.Dockerfile
    if (-not (Test-Path $dockerFile)) {
        Write-Warning "Custom Dockerfile '$dockerFile' not found, using default Dockerfile"
        $dockerFile = "Dockerfile"
    }
    
    docker build -f $dockerFile -t $Config.ImageName .
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker image '$($Config.ImageName)' built successfully!"
    } else {
        Write-Error "Failed to build Docker image"
        exit 1
    }
}

# Get or build the Docker image (try pull first, fallback to build)
function Get-Image {
    param([hashtable]$Config)
    
    # Check if image already exists locally
    $existingImage = docker images --format "table {{.Repository}}:{{.Tag}}" | Select-String $Config.ImageName
    if ($existingImage) {
        Write-Status "Local image '$($Config.ImageName)' already exists. Use 'rebuild' to force rebuild or 'pull' to update."
        return
    }
    
    # Try to pull from Docker Hub first
    if (Pull-Image $Config) {
        return
    } else {
        # Fallback to local build
        Build-Image $Config
    }
}

# Run the container
function Start-Container {
    param([string]$Platform, [hashtable]$Config)
    
    # Check if custom compose file exists, otherwise use default
    $composeFile = $Config.ComposeFile
    if (-not (Test-Path $composeFile)) {
        Write-Warning "Custom compose file '$composeFile' not found, using default docker-compose.yml"
        $composeFile = "docker-compose.yml"
    }
    
    Write-Status "Using configuration: $composeFile"
    
    # Check if container is already running
    $runningContainer = docker ps --filter "name=$($Config.ContainerName)" --format "{{.Names}}"
    if ($runningContainer -eq $Config.ContainerName) {
        Write-Warning "Container $($Config.ContainerName) is already running. Stopping it first..."
        docker-compose -f $composeFile down
    }
    
    Write-Status "Starting development environment: $($Config.ContainerName)..."
    
    # Set environment variables for docker-compose
    $env:CONTAINER_NAME = $Config.ContainerName
    $env:IMAGE_NAME = $Config.ImageName
    $env:WORKSPACE_PATH = $Config.WorkspacePath
    $env:HELM_PATH = $Config.HelmPath
    
    docker-compose -f $composeFile up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Development environment '$($Config.ContainerName)' is running!"
        Write-Status "Connect with: docker exec -it $($Config.ContainerName) zsh"
        Write-Status "Or use: .\devenv.ps1 $Profile connect"
    } else {
        Write-Error "Failed to start development environment"
        exit 1
    }
}

# Connect to running container
function Connect-Container {
    param([hashtable]$Config)
    
    $runningContainer = docker ps --filter "name=$($Config.ContainerName)" --format "{{.Names}}"
    if ($runningContainer -ne $Config.ContainerName) {
        Write-Error "Container '$($Config.ContainerName)' is not running. Start it first with: .\devenv.ps1 $Profile run"
        exit 1
    }
    
    Write-Status "Connecting to development environment: $($Config.ContainerName)..."
    docker exec -it $Config.ContainerName zsh
}

# Stop the container
function Stop-Container {
    param([string]$Platform, [hashtable]$Config)
    
    $composeFile = $Config.ComposeFile
    if (-not (Test-Path $composeFile)) {
        $composeFile = "docker-compose.yml"
    }
    
    Write-Status "Stopping development environment: $($Config.ContainerName)..."
    
    # Set environment variables for docker-compose
    $env:CONTAINER_NAME = $Config.ContainerName
    $env:IMAGE_NAME = $Config.ImageName
    $env:WORKSPACE_PATH = $Config.WorkspacePath
    $env:HELM_PATH = $Config.HelmPath
    
    docker-compose -f $composeFile down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Development environment '$($Config.ContainerName)' stopped!"
    } else {
        Write-Error "Failed to stop development environment"
        exit 1
    }
}

# Show help
function Show-Help {
    Write-Host "Rustam's Development Environment Manager for Windows" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Usage: .\devenv.ps1 [PROFILE] [COMMAND]" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "Profiles:" -ForegroundColor $Yellow
    Write-Host "  personal     Personal development environment (default)"
    Write-Host "  work_sarna   Work environment for Sarna project"
    Write-Host "  work_sdui    Work environment for SDUI project"
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $Yellow
    Write-Host "  run        Pull/build image (if needed) and start container"
    Write-Host "  pull       Pull pre-built image from Docker Hub"
    Write-Host "  build      Build Docker image locally"
    Write-Host "  rebuild    Force rebuild Docker image locally"
    Write-Host "  connect    Connect to running environment"
    Write-Host "  stop       Stop the development environment"
    Write-Host "  restart    Restart the development environment"
    Write-Host "  logs       Show container logs"
    Write-Host "  status     Show container status"
    Write-Host "  help       Show this help message"
    Write-Host ""
    Write-Host "Profile Configurations:" -ForegroundColor $Yellow
    Write-Host "  personal     → C:\workspace & C:\helm"
    Write-Host "  work_sarna   → C:\workspace\sarna & C:\helm\sarna"
    Write-Host "  work_sdui    → C:\workspace\sdui & C:\helm\sdui"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $Yellow
    Write-Host "  .\devenv.ps1 personal run       # Start personal environment"
    Write-Host "  .\devenv.ps1 work_sarna connect # Connect to Sarna environment"
    Write-Host "  .\devenv.ps1 work_sdui stop     # Stop SDUI environment"
    Write-Host "  .\devenv.ps1 status             # Show all containers"
}

# Show container logs
function Show-Logs {
    param([string]$Platform, [hashtable]$Config)
    
    $composeFile = $Config.ComposeFile
    if (-not (Test-Path $composeFile)) {
        $composeFile = "docker-compose.yml"
    }
    
    # Set environment variables for docker-compose
    $env:CONTAINER_NAME = $Config.ContainerName
    $env:IMAGE_NAME = $Config.ImageName
    $env:WORKSPACE_PATH = $Config.WorkspacePath
    $env:HELM_PATH = $Config.HelmPath
    
    docker-compose -f $composeFile logs -f
}

# Show container status
function Show-Status {
    Write-Host "=== Docker Images ===" -ForegroundColor $Blue
    $images = docker images --filter "reference=rustam-devenv" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    if ($images.Count -gt 1) {
        $images
    } else {
        Write-Host "No rustam-devenv images found"
    }
    
    Write-Host ""
    Write-Host "=== Running Containers ===" -ForegroundColor $Blue
    $runningContainers = docker ps --filter "name=rustam-devenv" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    if ($runningContainers.Count -gt 1) {
        $runningContainers
    } else {
        Write-Host "No rustam-devenv containers running"
    }
    
    Write-Host ""
    Write-Host "=== All Containers ===" -ForegroundColor $Blue
    $allContainers = docker ps -a --filter "name=rustam-devenv" --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"
    if ($allContainers.Count -gt 1) {
        $allContainers
    } else {
        Write-Host "No rustam-devenv containers found"
    }
}

# Check prerequisites
function Test-Prerequisites {
    param([hashtable]$Config)
    
    # Check if Docker is installed
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Error "Docker is not installed or not in PATH"
        Write-Host "Please install Docker Desktop for Windows from: https://docs.docker.com/desktop/windows/install/"
        exit 1
    }
    
    # Check if Docker Compose is installed
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Error "Docker Compose is not installed or not in PATH"
        Write-Host "Docker Compose should be included with Docker Desktop"
        exit 1
    }
    
    # Check if Docker is running
    try {
        docker info | Out-Null
    } catch {
        Write-Error "Docker is not running. Please start Docker Desktop"
        exit 1
    }
    
    # Create profile-specific directories
    Write-Status "Ensuring source directories exist for profile..."
    
    $workspacePath = $Config.WorkspacePath
    $helmPath = $Config.HelmPath
    
    if (-not (Test-Path $workspacePath)) {
        Write-Status "Creating $workspacePath..."
        New-Item -ItemType Directory -Path $workspacePath -Force | Out-Null
    }
    
    if (-not (Test-Path $helmPath)) {
        Write-Status "Creating $helmPath..."
        New-Item -ItemType Directory -Path $helmPath -Force | Out-Null
    }
    
    Write-Success "Source directories are ready!"
    Write-Status "Workspace: $workspacePath"
    Write-Status "Helm: $helmPath"
}

# Main script logic
function Main {
    param([string]$Profile, [string]$Command)
    
    # Validate profile
    Test-Profile $Profile
    
    # Get profile configuration
    $config = Get-ProfileConfig $Profile
    
    $platform = Get-Platform
    Write-Status "Detected platform: $platform"
    Write-Status "Using profile: $Profile"
    
    # Test prerequisites first
    Test-Prerequisites $config
    
    switch ($Command.ToLower()) {
        "build" {
            Build-Image $config
        }
        "pull" {
            Pull-Image $config
        }
        "rebuild" {
            Build-Image $config
        }
        "run" {
            Get-Image $config
            Start-Container $platform $config
        }
        "connect" {
            Connect-Container $config
        }
        "exec" {
            Connect-Container $config
        }
        "shell" {
            Connect-Container $config
        }
        "stop" {
            Stop-Container $platform $config
        }
        "restart" {
            Stop-Container $platform $config
            Start-Sleep 2
            Get-Image $config
            Start-Container $platform $config
        }
        "logs" {
            Show-Logs $platform $config
        }
        "status" {
            Show-Status
        }
        "help" {
            Show-Help
        }
        "-h" {
            Show-Help
        }
        "--help" {
            Show-Help
        }
        default {
            Write-Error "Unknown command: $Command"
            Show-Help
            exit 1
        }
    }
}

# Run the main function
Main $Profile $Command
