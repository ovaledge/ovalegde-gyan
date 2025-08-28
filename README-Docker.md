# OvalEdge Gyan Docker Setup

This directory contains Docker configuration files for building and running OvalEdge Gyan from the `oe-main` branch of the [ovaledge/ovalegde-gyan](https://github.com/ovaledge/ovalegde-gyan) repository.

## Files Overview

- `Dockerfile.ovaledge` - Multi-stage Docker build file for OvalEdge Gyan
- `.dockerignore.ovaledge` - Docker ignore file to optimize build context
- `build-ovaledge.sh` - Build script with various options
- `docker-compose.ovaledge.yml` - Complete stack with PostgreSQL and Redis
- `README-Docker.md` - This documentation file

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. **Start the complete stack:**
   ```bash
   docker-compose -f docker-compose.ovaledge.yml up -d
   ```

2. **Access the application:**
   - Open http://localhost:3000 in your browser
   - The application will be available after the initial setup

3. **Stop the stack:**
   ```bash
   docker-compose -f docker-compose.ovaledge.yml down
   ```

### Option 2: Using the Build Script

1. **Build the Docker image:**
   ```bash
   ./build-ovaledge.sh
   ```

2. **Run the container:**
   ```bash
   docker run -p 3000:3000 ovaledge-gyan:latest
   ```

## Build Script Usage

The `build-ovaledge.sh` script provides various options for building the Docker image:

```bash
# Basic usage
./build-ovaledge.sh

# Build with specific tag
./build-ovaledge.sh -t v1.0.0

# Build from different branch
./build-ovaledge.sh -b main -t main-latest

# Build without cache
./build-ovaledge.sh --no-cache

# Build and push to registry
./build-ovaledge.sh --push

# Show help
./build-ovaledge.sh --help
```

### Build Script Options

- `-t, --tag TAG` - Docker image tag (default: latest)
- `-n, --name NAME` - Docker image name (default: ovaledge-gyan)
- `-b, --branch BRANCH` - Git branch to build from (default: oe-main)
- `-r, --repo URL` - Git repository URL
- `--no-cache` - Build without using cache
- `--push` - Push image to registry after building
- `-h, --help` - Show help message

## Manual Docker Build

If you prefer to build manually:

```bash
# Build the image
docker build -f Dockerfile.ovaledge \
  --build-arg REPO_URL=https://github.com/ovaledge/ovalegde-gyan \
  --build-arg BRANCH=oe-main \
  -t ovaledge-gyan:latest .

# Run the container
docker run -p 3000:3000 ovaledge-gyan:latest
```

## Environment Configuration

### Required Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `SECRET_KEY` - Application secret key
- `UTILS_SECRET` - Utils secret key

### Optional Environment Variables

- `URL` - Public URL of the application
- `FILE_STORAGE` - File storage type (local, s3, etc.)
- `SMTP_*` - Email configuration
- `SENTRY_DSN` - Sentry error tracking

## Production Deployment

### Security Considerations

1. **Change default secrets:**
   ```bash
   # Generate secure secrets
   openssl rand -hex 32  # For SECRET_KEY
   openssl rand -hex 32  # For UTILS_SECRET
   ```

2. **Use environment files:**
   ```bash
   # Create .env file
   cat > .env << EOF
   SECRET_KEY=your-generated-secret-key
   UTILS_SECRET=your-generated-utils-secret
   DATABASE_URL=postgres://user:password@host:5432/database
   REDIS_URL=redis://host:6379
   URL=https://your-domain.com
   EOF
   ```

3. **Configure reverse proxy:**
   - Use Nginx or Apache as reverse proxy
   - Enable SSL/TLS certificates
   - Configure proper headers

### Database Setup

The Docker Compose setup includes PostgreSQL and Redis. For production:

1. **Use managed databases** (AWS RDS, Google Cloud SQL, etc.)
2. **Configure backups** and monitoring
3. **Set up connection pooling**

### File Storage

For production, consider using cloud storage:

```yaml
environment:
  FILE_STORAGE: s3
  AWS_ACCESS_KEY_ID: your-access-key
  AWS_SECRET_ACCESS_KEY: your-secret-key
  AWS_S3_BUCKET_NAME: your-bucket-name
  AWS_S3_REGION: us-east-1
```

## Monitoring and Health Checks

The Docker setup includes health checks for all services:

- **Application:** HTTP health check on `/_health` endpoint
- **PostgreSQL:** `pg_isready` command
- **Redis:** `redis-cli ping` command

## Troubleshooting

### Common Issues

1. **Build fails with memory error:**
   ```bash
   # Increase Node.js memory limit
   export NODE_OPTIONS="--max-old-space-size=8192"
   ./build-ovaledge.sh
   ```

2. **Database connection issues:**
   - Check if PostgreSQL container is running
   - Verify database credentials
   - Check network connectivity

3. **Application won't start:**
   - Check logs: `docker logs ovaledge-gyan-app`
   - Verify environment variables
   - Check file permissions

### Logs

```bash
# View application logs
docker logs ovaledge-gyan-app

# View all service logs
docker-compose -f docker-compose.ovaledge.yml logs

# Follow logs in real-time
docker-compose -f docker-compose.ovaledge.yml logs -f
```

## Development

For development with hot reloading:

```bash
# Clone the repository
git clone https://github.com/ovaledge/ovalegde-gyan.git
cd ovalegde-gyan
git checkout oe-main

# Install dependencies
yarn install

# Start development server
yarn dev
```

## Support

For issues related to:
- **OvalEdge Gyan:** [GitHub Issues](https://github.com/ovaledge/ovalegde-gyan/issues)
- **Docker Setup:** Check this README or create an issue

## License

This Docker setup is provided as-is. Please refer to the main project license for usage terms.
