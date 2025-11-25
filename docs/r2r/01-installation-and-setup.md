# R2R Installation and Setup

## Overview

R2R (RAG to Riches) is a production-ready AI retrieval system offering cutting-edge search capabilities like hybrid search, knowledge graphs, and agentic RAG. This guide covers various installation methods and initial setup.

## Prerequisites

- Docker and Docker Compose (recommended)
- Python 3.8+ (for Python SDK)
- Node.js and npm (for JavaScript SDK)
- OpenAI API key (or other LLM provider)

## Installation Methods

### 1. Quick Start with Docker

The fastest way to get R2R running is using Docker Compose:

```bash
# Clone the repository
git clone git@github.com:SciPhi-AI/R2R.git && cd R2R

# Set required environment variables
export OPENAI_API_KEY=sk-...

# Start R2R in full mode
docker compose up
```

For a more comprehensive setup with full features:

```bash
export R2R_CONFIG_NAME=full
export OPENAI_API_KEY=sk-...

docker compose -f compose.full.yaml --profile postgres up -d
```

### 2. Docker Installation on Ubuntu

If Docker is not installed on your system, use these commands for Ubuntu:

```bash
# Update package list
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add your user to the Docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify Docker installation
docker run hello-world
```

### 3. Python Installation

Install R2R using pip for direct Python integration:

```bash
# Install R2R Python SDK
pip install r2r

# Set API key
export OPENAI_API_KEY=sk-...

# Run in light mode
python -m r2r.serve
```

Alternative full installation:

```bash
pip install r2r-python-sdk
```

### 4. JavaScript Installation

For Node.js projects, install the R2R JavaScript SDK:

```bash
npm install r2r-js
```

### 5. Google Cloud Platform (GCP) Installation

Installing R2R on a GCP VM instance:

```bash
# Update system packages
sudo apt update
sudo apt install python3-pip -y

# Install R2R
pip install r2r

# Add R2R to PATH
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

## Starting the R2R Server

### Option 1: Docker with Custom Configuration

```bash
# Set required remote providers
export OPENAI_API_KEY=sk-...

# Start with optional custom configuration
r2r serve --docker --full
```

### Option 2: Light Mode (Python)

```bash
# Quick start without Docker
pip install r2r
export OPENAI_API_KEY=sk-...
python -m r2r.serve
```

### Option 3: Full Mode with Docker

```bash
# Clone repository
git clone git@github.com:SciPhi-AI/R2R.git && cd R2R

# Set environment variables
export R2R_CONFIG_NAME=full
export OPENAI_API_KEY=sk-...

# Start full stack
docker compose -f compose.full.yaml --profile postgres up -d
```

## Web Development Setup

For the R2R Web Dev Template:

```bash
# Install dependencies
pnpm install

# Configure environment
cp .env.example .env
nano .env
```

## Verifying Installation

After installation, verify R2R is running correctly:

```bash
# Check service status
curl http://localhost:7272/v3/system/settings

# Or use the CLI
r2r --help
```

## Environment Configuration

### Required Environment Variables

```bash
# LLM Provider (OpenAI example)
export OPENAI_API_KEY=sk-...

# Optional: Custom configuration path
export R2R_CONFIG_PATH=/app/user_configs/my_custom_config.toml

# Optional: Configuration name
export R2R_CONFIG_NAME=full
```

### Configuration File Location

By default, R2R looks for configuration in:
- Docker: `/app/user_configs/<config>.toml`
- Local: `~/.r2r/r2r.toml`

## Next Steps

After installation:

1. **Ingest Documents**: Start adding documents to your R2R instance
2. **Configure Settings**: Customize R2R behavior via `r2r.toml`
3. **Test Retrieval**: Run search and RAG queries
4. **Set Up Collections**: Organize documents into collections
5. **Configure Authentication**: Enable user management and security

## Common Issues

### Docker Permission Errors

If you encounter permission errors:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Port Already in Use

If port 7272 is already in use:

```bash
# Check what's using the port
sudo lsof -i :7272

# Kill the process or change R2R port in configuration
```

### API Key Not Found

Ensure environment variables are properly set:

```bash
# Check current environment
echo $OPENAI_API_KEY

# If empty, export again
export OPENAI_API_KEY=sk-...
```

## Resources

- [R2R GitHub Repository](https://github.com/sciphi-ai/r2r)
- [R2R Documentation](https://r2r-docs.sciphi.ai)
- [Python SDK Documentation](https://github.com/sciphi-ai/r2r/tree/main/py/sdk)
- [JavaScript SDK Documentation](https://github.com/sciphi-ai/r2r/tree/main/js)
