#!/bin/bash

# Build script for OvalEdge Gyan Docker image
# This script builds a Docker image from the oe-main branch

set -e

# Configuration
REPO_URL="https://github.com/ovaledge/ovalegde-gyan"
BRANCH="oe-main"
IMAGE_NAME="ovaledge-gyan"
TAG="latest"
DOCKERFILE="Dockerfile.ovaledge"
DOCKERIGNORE=".dockerignore.ovaledge"

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --tag TAG        Docker image tag (default: latest)"
    echo "  -n, --name NAME      Docker image name (default: ovaledge-gyan)"
    echo "  -b, --branch BRANCH  Git branch to build from (default: oe-main)"
    echo "  -r, --repo URL       Git repository URL (default: https://github.com/ovaledge/ovalegde-gyan)"
    echo "  --no-cache          Build without using cache"
    echo "  --push              Push image to registry after building"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build with default settings"
    echo "  $0 -t v1.0.0                        # Build with specific tag"
    echo "  $0 --no-cache --push                 # Build without cache and push"
    echo "  $0 -b main -t main-latest            # Build from main branch"
}

# Parse command line arguments
NO_CACHE=""
PUSH_IMAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -r|--repo)
            REPO_URL="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --push)
            PUSH_IMAGE="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ -z "$TAG" ]]; then
    print_error "Tag cannot be empty"
    exit 1
fi

if [[ -z "$IMAGE_NAME" ]]; then
    print_error "Image name cannot be empty"
    exit 1
fi

if [[ -z "$BRANCH" ]]; then
    print_error "Branch cannot be empty"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if required files exist
if [[ ! -f "$DOCKERFILE" ]]; then
    print_error "Dockerfile not found: $DOCKERFILE"
    exit 1
fi

if [[ ! -f "$DOCKERIGNORE" ]]; then
    print_warning "Dockerignore file not found: $DOCKERIGNORE"
fi

# Display build configuration
print_status "Build Configuration:"
echo "  Repository: $REPO_URL"
echo "  Branch: $BRANCH"
echo "  Image Name: $IMAGE_NAME"
echo "  Tag: $TAG"
echo "  Dockerfile: $DOCKERFILE"
echo "  No Cache: ${NO_CACHE:-false}"
echo "  Push After Build: ${PUSH_IMAGE:-false}"
echo ""

# Build the Docker image
print_status "Building Docker image..."

BUILD_ARGS="--build-arg REPO_URL=$REPO_URL --build-arg BRANCH=$BRANCH"

if [[ -n "$NO_CACHE" ]]; then
    BUILD_ARGS="$BUILD_ARGS $NO_CACHE"
fi

if ! docker build \
    -f "$DOCKERFILE" \
    -t "$IMAGE_NAME:$TAG" \
    $BUILD_ARGS \
    .; then
    print_error "Docker build failed"
    exit 1
fi

print_success "Docker image built successfully: $IMAGE_NAME:$TAG"

# Push image if requested
if [[ "$PUSH_IMAGE" == "true" ]]; then
    print_status "Pushing image to registry..."
    if docker push "$IMAGE_NAME:$TAG"; then
        print_success "Image pushed successfully: $IMAGE_NAME:$TAG"
    else
        print_error "Failed to push image"
        exit 1
    fi
fi

# Show image information
print_status "Image Information:"
docker images "$IMAGE_NAME:$TAG"

print_success "Build completed successfully!"
print_status "To run the container:"
echo "  docker run -p 3000:3000 $IMAGE_NAME:$TAG"
