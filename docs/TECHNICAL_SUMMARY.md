# Caremate DevOps - Comprehensive Technical Summary

**Version:** 1.0
**Last Updated:** 2025-11-16
**Project:** Caremate Healthcare Platform Infrastructure

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Technology Stack](#technology-stack)
4. [Infrastructure Components](#infrastructure-components)
5. [Prerequisites](#prerequisites)
6. [Complete Setup Guide](#complete-setup-guide)
7. [Running the Application](#running-the-application)
8. [Debugging Guide](#debugging-guide)
9. [Modifying Existing Modules](#modifying-existing-modules)
10. [Security & Best Practices](#security--best-practices)
11. [Troubleshooting](#troubleshooting)
12. [Reference](#reference)

---

## Executive Summary

**Caremate DevOps** is an Infrastructure-as-Code (IaC) repository that provisions and manages a cloud-native healthcare platform on Google Cloud Platform (GCP). The system consists of multiple microservices orchestrated via Docker Compose, deployed across two primary servers using Ansible automation.

### Key Characteristics:

- **Cloud Platform:** Google Cloud Platform (Project: `beaming-key-466311-v1`)
- **Infrastructure:** Terraform-managed compute instances
- **Configuration Management:** Ansible playbooks and roles
- **Deployment Model:** Container-based microservices with Docker Compose
- **Architecture:** Multi-server setup (Caremate Server, Jitsi Video Server)
- **Security:** Let's Encrypt SSL/TLS, Firebase authentication, vault-encrypted secrets

### Primary Servers:

1. **caremate-server** (34.126.130.128) - Main application backend and microservices
2. **jitsi-server** (34.142.157.137) - Video conferencing platform

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Google Cloud Platform                         │
│                   (beaming-key-466311-v1)                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┴─────────────────────┐
        │                                           │
        ▼                                           ▼
┌──────────────────┐                      ┌──────────────────┐
│ Caremate Server  │                      │  Jitsi Server    │
│ (e2-standard-2)  │                      │  (e2-medium)     │
│ 8GB RAM, 2vCPU   │                      │  4GB RAM, 2vCPU  │
│ 34.126.130.128   │                      │ 34.142.157.137   │
└──────────────────┘                      └──────────────────┘
        │                                           │
        │                                           │
        ▼                                           ▼
┌──────────────────────────────────┐    ┌──────────────────────┐
│    Docker Compose Network        │    │  Jitsi Docker Stack  │
│    (caremate-network)            │    │                      │
│                                  │    │ • Prosody (XMPP)     │
│ • PostgreSQL (5432)              │    │ • JVB (Video Bridge) │
│ • Redis (6379)                   │    │ • Jicofo (Focus)     │
│ • Neo4j (7474, 7687)             │    │ • Jitsi Web          │
│ • Nginx (80, 443)                │    │ • Transcriber        │
│ • caremate-server (8103)         │    │                      │
│ • cengine-api (8003)             │    └──────────────────────┘
│ • care-assistant (3002)          │
│ • ai-scribe (8000)               │
│ • mental-care (8004)             │
│ • caremate-mcp                   │
│ • chroma-server (8001)           │
└──────────────────────────────────┘
```

### Service Communication Flow

```
Internet (HTTPS)
      │
      ▼
┌─────────────┐
│   Nginx     │ (Reverse Proxy, SSL Termination)
│  Port 80/443│
└─────────────┘
      │
      ├─────────► caremate-server:8103   (Main API - Node.js)
      │
      ├─────────► cengine-api:8003       (C-Engine - Python/FastAPI)
      │
      ├─────────► care-assistant:3002    (Assistant - Python)
      │
      ├─────────► ai-scribe:8000         (Scribe - Python/FastAPI)
      │
      ├─────────► mental-care:8004       (Mental Health - Python)
      │
      └─────────► neo4j:7474             (Graph DB Web UI)


Database Layer:
      │
      ├─────────► PostgreSQL:5432        (Primary Database)
      │
      ├─────────► Neo4j:7687             (Graph Database - Bolt Protocol)
      │
      └─────────► Redis:6379             (Cache & Job Queue)
```

---

## Technology Stack

### Infrastructure & Cloud

| Component              | Technology                | Version                  |
| ---------------------- | ------------------------- | ------------------------ |
| Cloud Provider         | Google Cloud Platform     | -                        |
| Infrastructure as Code | Terraform                 | ~1.0                     |
| GCP Provider           | terraform-google-provider | ~5.38.0                  |
| Compute                | Google Compute Engine     | e2-medium, e2-standard-2 |
| Storage                | Google Cloud Storage      | State backend            |
| Authentication         | GCP Service Accounts      | IAM-based                |

### Configuration Management

| Component          | Technology    | Version |
| ------------------ | ------------- | ------- |
| Automation Tool    | Ansible       | 2.9+    |
| Python             | Python        | 3.x     |
| SSH Keys           | Ed25519, RSA  | -       |
| Secrets Management | Ansible Vault | -       |

### Container & Orchestration

| Component         | Technology     | Version |
| ----------------- | -------------- | ------- |
| Container Runtime | Docker CE      | Latest  |
| Orchestration     | Docker Compose | Plugin  |
| Build Tools       | docker-buildx  | Plugin  |

### Application Runtime

| Component              | Technology | Version  |
| ---------------------- | ---------- | -------- |
| Backend Runtime        | Node.js    | 22.x LTS |
| Python Runtime         | Python     | 3.x      |
| Package Managers       | npm, Yarn  | Latest   |
| Python Package Manager | Poetry     | Latest   |

### Databases

| Component     | Technology | Port                     | Purpose                                   |
| ------------- | ---------- | ------------------------ | ----------------------------------------- |
| Relational DB | PostgreSQL | 5432                     | Primary data store (medplum, cengine_api) |
| Graph DB      | Neo4j      | 7474 (HTTP), 7687 (Bolt) | Knowledge graphs                          |
| Cache/Queue   | Redis      | 6379                     | Caching & BullMQ job queue                |
| Vector DB     | Chroma     | 8001                     | AI embeddings                             |

### Microservices Framework

| Component       | Technology      | Language              | Port |
| --------------- | --------------- | --------------------- | ---- |
| caremate-server | Medplum/Node.js | TypeScript/JavaScript | 8103 |
| cengine-api     | FastAPI         | Python                | 8003 |
| care-assistant  | Custom          | Python                | 3002 |
| ai-scribe       | FastAPI         | Python                | 8000 |
| mental-care     | Custom          | Python                | 8004 |
| caremate-mcp    | Custom          | Python                | TBD  |

### Web Services & Security

| Component      | Technology              | Purpose                  |
| -------------- | ----------------------- | ------------------------ |
| Reverse Proxy  | Nginx                   | SSL termination, routing |
| SSL/TLS        | Let's Encrypt (Certbot) | HTTPS certificates       |
| Authentication | Firebase                | User authentication      |
| OAuth          | OpenID Connect          | OAuth 2.0 support        |
| Bot Protection | Google reCAPTCHA        | Form protection          |

### Video Conferencing

| Component        | Technology | Purpose               |
| ---------------- | ---------- | --------------------- |
| Video Platform   | Jitsi Meet | Video calls           |
| XMPP Server      | Prosody    | Messaging             |
| Video Bridge     | JVB        | Video routing         |
| Conference Focus | Jicofo     | Conference management |
| Transcription    | Jigasi     | Speech-to-text        |

### Message Queue & Jobs

| Component      | Technology | Purpose                   |
| -------------- | ---------- | ------------------------- |
| Job Queue      | BullMQ     | Background job processing |
| Message Broker | Redis      | BullMQ backend            |

---

## Infrastructure Components

### Server Specifications

#### Caremate Server

- **Instance Type:** e2-standard-2
- **vCPUs:** 2
- **RAM:** 8 GB
- **Disk:** Boot disk (Ubuntu)
- **Public IP:** 34.126.130.128
- **Hostname:** caremate-server
- **OS:** Ubuntu 20.04+ LTS
- **Purpose:** Primary application server, databases, microservices

#### Jitsi Server

- **Instance Type:** e2-medium
- **vCPUs:** 2
- **RAM:** 4 GB
- **Disk:** Boot disk (Ubuntu)
- **Public IP:** 34.142.157.137
- **Hostname:** jitsi-server
- **OS:** Ubuntu 20.04+ LTS
- **Purpose:** Video conferencing platform

### Network Architecture

#### Firewall Rules

- **Port 22:** SSH access (limited to authorized IPs)
- **Port 80:** HTTP (redirects to HTTPS)
- **Port 443:** HTTPS (SSL/TLS)
- **Port 5222:** XMPP Client (Jitsi)
- **Port 5349:** TURN/STUN (Jitsi)
- **Port 7474:** Neo4j HTTP
- **Port 7687:** Neo4j Bolt
- **Port 10000 UDP:** JVB Video (Jitsi)

#### DNS Configuration

- **api.fpt-healthcare.com** → 34.126.130.128 (caremate-server)
- **jitsi.yourdomain.com** → 34.142.157.137 (jitsi-server)

### Storage & State Management

- **Terraform State:** Google Cloud Storage bucket (`${PROJECT_ID}-state`)
- **Docker Volumes:** Persistent volumes for PostgreSQL, Neo4j, Redis
- **Binary Storage:** File system storage for caremate-server uploads

---

## Prerequisites

### Local Development Machine Requirements

#### Required Software

1. **Operating System:** Linux, macOS, or Windows with WSL2
2. **Google Cloud CLI (`gcloud`):** Latest version
   - Installation: https://cloud.google.com/sdk/docs/install
3. **Terraform:** Version 1.0 or higher
   - Installation: https://www.terraform.io/downloads
4. **Ansible:** Version 2.9 or higher
   - Installation: `pip install ansible`
5. **Python:** Version 3.8 or higher
6. **Git:** Latest version
7. **SSH Client:** OpenSSH or equivalent

#### Google Cloud Platform Account

- Active GCP account with billing enabled
- Project created (e.g., `beaming-key-466311-v1`)
- Sufficient quotas for Compute Engine instances
- IAM permissions:
  - Compute Admin
  - Service Account Admin
  - Storage Admin
  - Billing Account User

#### SSH Key Pair

- Ed25519 or RSA SSH key pair generated
- Public key added to GCP Compute Engine metadata
- Private key available on local machine (`~/.ssh/id_ed25519` or `~/.ssh/id_rsa`)

#### Domain & DNS

- Registered domain name (e.g., `fpt-healthcare.com`)
- Access to DNS management (Namecheap, Cloudflare, etc.)
- Ability to create A records

#### Required Credentials (Vault-Encrypted)

The following credentials must be configured in `playbooks/group_vars/all/vault.yml`:

- PostgreSQL username/password
- SMTP credentials (Gmail)
- API keys (OpenAI, Gemini, Mistral, Google)
- Neo4j password
- Chroma API key
- Firebase service account
- reCAPTCHA keys
- Database connection strings

#### Network Access

- SSH access to GCP instances (port 22)
- Ability to make outbound HTTPS requests
- No corporate firewall blocking GCP API calls

---

## Complete Setup Guide

This section provides step-by-step instructions to set up the Caremate infrastructure from scratch.

### Phase 1: Local Environment Setup

#### Step 1: Install Google Cloud CLI

**On Linux/macOS:**

```bash
# Download and run the installer
curl https://sdk.cloud.google.com | bash

# Restart your shell
exec -l $SHELL

# Initialize gcloud
gcloud init
```

**On Windows (WSL2):**

```bash
# Same as Linux
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

**Verify installation:**

```bash
gcloud version
```

#### Step 2: Install Terraform

**On Linux:**

```bash
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
```

**On macOS:**

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform --version
```

#### Step 3: Install Ansible

```bash
# Using pip (recommended)
pip install ansible

# Verify installation
ansible --version
```

#### Step 4: Clone the Repository

```bash
git clone git@github.com:nguyen2v/caremate-devops.git
cd caremate-devops
```

---

### Phase 2: Google Cloud Platform Setup

#### Step 5: Authenticate with Google Cloud

```bash
# Login to Google Cloud
gcloud auth login

# Set application-default credentials
gcloud auth application-default login
```

Follow the browser prompts to authenticate.

#### Step 6: Set Default Project

```bash
# Set your project ID
export PROJECT_ID="beaming-key-466311-v1"

# Set default project
gcloud config set project ${PROJECT_ID}

# Set quota project for ADC
gcloud auth application-default set-quota-project ${PROJECT_ID}

# Verify current project
gcloud config get-value project
```

#### Step 7: Enable Required GCP Services

```bash
# Enable necessary APIs
services=(
  compute.googleapis.com
  billingbudgets.googleapis.com
  iam.googleapis.com
  cloudresourcemanager.googleapis.com
)

for service in "${services[@]}"; do
  echo "Enabling ${service}..."
  gcloud services enable ${service}
done

# Verify enabled services
gcloud services list --enabled
```

#### Step 8: Create GCS Backend for Terraform State

```bash
# Create storage bucket for Terraform state
gcloud storage buckets create gs://${PROJECT_ID}-state \
  --location=ASIA-SOUTHEAST1 \
  --uniform-bucket-level-access

# Verify bucket creation
gcloud storage buckets list
```

---

### Phase 3: Infrastructure Provisioning with Terraform

#### Step 9: Initialize Terraform

```bash
cd caremate-devops

# Initialize Terraform (downloads providers, sets up backend)
terraform -chdir=beaming-key-466311-v1 init
```

Expected output:

```
Initializing the backend...
Successfully configured the backend "gcs"!
Terraform has been successfully initialized!
```

#### Step 10: Review Terraform Configuration

**Key files to understand:**

1. **`beaming-key-466311-v1/providers.tf`**: GCP provider configuration
2. **`beaming-key-466311-v1/locals.tf`**: Variables (project ID, machine types, regions)
3. **`beaming-key-466311-v1/servers.tf`**: Compute instance definitions
4. **`beaming-key-466311-v1/service-account.tf`**: Service account and IAM roles
5. **`beaming-key-466311-v1/firewall.tf`**: Firewall rules (in module)

**Review local variables:**

```bash
cat beaming-key-466311-v1/locals.tf
```

**Customize if needed:**

- Machine types
- Zones/regions
- Network settings

#### Step 11: Plan Infrastructure Changes

```bash
# Generate execution plan
terraform -chdir=beaming-key-466311-v1 plan
```

Review the plan carefully. You should see:

- 2 compute instances (caremate-server, jitsi-server)
- Firewall rules
- Service accounts
- IAM bindings

#### Step 12: Apply Infrastructure

```bash
# Create infrastructure
terraform -chdir=beaming-key-466311-v1 apply -auto-approve
```

**This will create:**

- Caremate server instance
- Jitsi server instance
- Firewall rules
- Service accounts with necessary permissions

**Wait for completion** (typically 2-5 minutes).

#### Step 13: Verify Infrastructure

```bash
# List created instances
gcloud compute instances list

# Expected output:
# NAME             ZONE           MACHINE_TYPE   INTERNAL_IP  EXTERNAL_IP      STATUS
# caremate-server  asia-southeast1-a  e2-standard-2  10.x.x.x     34.126.130.128  RUNNING
# jitsi-server     asia-southeast1-a  e2-medium      10.x.x.x     34.142.157.137  RUNNING
```

**Get external IPs:**

```bash
# Caremate server IP
gcloud compute instances describe caremate-server \
  --zone=asia-southeast1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'

# Jitsi server IP
gcloud compute instances describe jitsi-server \
  --zone=asia-southeast1-a \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

---

### Phase 4: DNS Configuration

#### Step 14: Configure DNS Records

**Login to your DNS provider** (Namecheap, Cloudflare, etc.) and add these records:

| Type     | Host  | Value          | TTL |
| -------- | ----- | -------------- | --- |
| A Record | api   | 34.126.130.128 | 300 |
| A Record | jitsi | 34.142.157.137 | 300 |

**Example for `fpt-healthcare.com`:**

- `api.fpt-healthcare.com` → `34.126.130.128`
- `jitsi.fpt-healthcare.com` → `34.142.157.137`

#### Step 15: Verify DNS Propagation

```bash
# Check DNS resolution
dig +short api.fpt-healthcare.com
# Should return: 34.126.130.128

dig +short jitsi.fpt-healthcare.com
# Should return: 34.142.157.137

# If not resolved, wait 5-10 minutes and retry
```

---

### Phase 5: Ansible Configuration

#### Step 16: Configure `/etc/hosts`

Add server IPs to your local `/etc/hosts` file for easier SSH access:

```bash
# Edit /etc/hosts (requires sudo)
sudo nano /etc/hosts

# Add these lines:
34.126.130.128 caremate-server
34.142.157.137 jitsi-server
```

**Verify:**

```bash
ping -c 3 caremate-server
ping -c 3 jitsi-server
```

#### Step 17: Configure SSH Access

**Test SSH connection:**

```bash
# SSH into caremate-server (user: dhp)
ssh dhp@caremate-server

# If connection fails, add your SSH key to the server:
gcloud compute ssh dhp@caremate-server --zone=asia-southeast1-a
```

**Exit the SSH session:**

```bash
exit
```

#### Step 18: Configure Ansible Inventory

**Edit `playbooks/inventory.ini`:**

```bash
cat playbooks/inventory.ini
```

**Ensure it contains:**

```ini
[caremate-server]
caremate-server ansible_host=34.126.130.128

[jitsi-server]
jitsi-server ansible_host=34.142.157.137
```

**Edit if needed:**

```bash
nano playbooks/inventory.ini
```

#### Step 19: Configure Ansible Vault

**Create vault password file** (DO NOT commit this):

```bash
echo "your-strong-vault-password" > ~/.ansible_vault_pass
chmod 600 ~/.ansible_vault_pass
```

**Edit vault file:**

```bash
ansible-vault edit playbooks/group_vars/all/vault.yml
```

**Add required secrets:**

```yaml
---
# PostgreSQL
postgres_username: medplum
postgres_password: 'your-postgres-password'

# SMTP (Gmail)
smtp_username: 'your-email@gmail.com'
smtp_password: 'your-gmail-app-password'

# API Keys
openai_api_key: 'sk-...'
gemini_api_key: '...'
google_api_key: '...'
mistral_api_key: '...'
chroma_api_key: '...'

# Neo4j
neo4j_password: 'your-neo4j-password'

# Cengine
alembic_database_url: 'postgresql://medplum:your-password@postgres:5432/cengine_api'
cengine_secret_key: 'your-secret-key'
```

**Verify vault configuration:**

```bash
ansible-vault view playbooks/group_vars/all/vault.yml
```

---

### Phase 6: Server Setup with Ansible

#### Step 20: Setup Core Packages

```bash
# Install essential system packages on caremate-server
ansible-playbook playbooks/setup-core-config.yaml \
  --limit=caremate-server \
  --verbose
```

**What this does:**

- Installs core utilities (curl, wget, git, build-essential)
- Configures shell (zsh/fish)
- Sets up locales (en_US.UTF-8)
- Updates system packages

**Expected duration:** 3-5 minutes

#### Step 21: Setup SSH Key

```bash
# Configure SSH keys for git operations
ansible-playbook playbooks/setup-ssh-key.yaml \
  --limit=caremate-server \
  --verbose
```

**What this does:**

- Copies SSH keys to server
- Configures git SSH authentication
- Sets proper permissions

#### Step 22: Setup Docker

```bash
# Install Docker Engine and plugins
ansible-playbook playbooks/setup-docker.yaml \
  --limit=caremate-server \
  --verbose
```

**What this does:**

- Adds Docker APT repository
- Installs docker-ce, docker-ce-cli, containerd.io
- Installs docker-compose-plugin, docker-buildx-plugin
- Adds user to docker group
- Starts Docker service

**Verify Docker installation:**

```bash
ssh dhp@caremate-server docker --version
# Expected: Docker version 24.x.x
```

**Expected duration:** 5-7 minutes

#### Step 23: Setup Node.js

```bash
# Install Node.js 22.x LTS and Yarn
ansible-playbook playbooks/setup-nodejs.yaml \
  --limit=caremate-server \
  --verbose
```

**What this does:**

- Adds NodeSource APT repository
- Installs Node.js 22.x
- Installs Yarn globally via npm

**Verify Node.js installation:**

```bash
ssh dhp@caremate-server "node --version && npm --version && yarn --version"
# Expected:
# v22.x.x
# 10.x.x
# 1.22.x
```

**Expected duration:** 3-5 minutes

#### Step 24: Setup Caremate Project

```bash
# Clone caremate repository and setup environment
ansible-playbook playbooks/setup-caremate-project.yaml --verbose
```

**What this does:**

- Clones `nguyen2v/caremate` repository to `/home/dhp/caremate-server`
- Creates `.env` file from template
- Creates `~/.caremate-config/caremate.config.json`
- Sets up project directory structure

**Verify project setup:**

```bash
ssh dhp@caremate-server "ls -la caremate-server/"
```

**Expected duration:** 2-3 minutes

---

### Phase 7: SSL/TLS Certificate Setup

#### Step 25: Setup Nginx (without SSL first)

```bash
# Setup Nginx reverse proxy without SSL
ansible-playbook playbooks/setup-nginx.yaml \
  --extra-vars='{ "ssl": false }' \
  --limit=caremate-server \
  --verbose
```

**What this does:**

- Installs Nginx
- Creates Nginx configuration for HTTP
- Starts Nginx service
- Prepares for Let's Encrypt challenge

**Expected duration:** 2-3 minutes

#### Step 26: Issue Let's Encrypt Certificate

```bash
# Issue HTTPS certificate using Certbot
ansible-playbook playbooks/setup-nginx.yaml \
  --limit=caremate-server \
  --verbose
```

**What this does:**

- Installs Certbot
- Requests SSL certificate from Let's Encrypt
- Configures Nginx for HTTPS
- Sets up automatic renewal

**Prerequisites:**

- DNS must be properly configured and propagated
- Port 80 must be accessible from the internet

**Verify certificate:**

```bash
ssh dhp@caremate-server "sudo certbot certificates"
```

**Expected duration:** 2-3 minutes

---

### Phase 8: Deploy Services

#### Step 27: Deploy Caremate Server

```bash
# Update environment variables
ansible-playbook playbooks/update-caremate-project-env.yaml --verbose

# Build and deploy main server
ansible-playbook playbooks/deploy-caremate-server.yaml --verbose
```

**What this does:**

1. Updates `.env` and `caremate.config.json`
2. Gets current Git SHA
3. Checks if Docker image exists
4. Runs `npm ci` (install dependencies)
5. Runs `npm run build:fast`
6. Builds Docker image: `caremate-server:${GIT_SHA}`
7. Starts `postgres`, `redis` containers
8. Starts `caremate-server` container

**Expected duration:** 10-15 minutes (first build)

**Verify deployment:**

```bash
ssh dhp@caremate-server "docker ps"
```

Expected containers:

- `postgres`
- `redis`
- `caremate-server`

#### Step 28: Deploy Additional Services

**Deploy AI Scribe:**

```bash
ansible-playbook playbooks/deploy-ai-scribe.yaml --verbose
```

**Deploy Care Assistant:**

```bash
ansible-playbook playbooks/deploy-care-assistant.yaml --verbose
```

**Deploy Caremate MCP:**

```bash
ansible-playbook playbooks/deploy-caremate-mcp.yaml --verbose
```

**Deploy C-Engine API:**

```bash
ansible-playbook playbooks/deploy-caremate-service.yaml \
  --extra-vars='{ "service_name": "cengine-api" }' \
  --verbose
```

**Seed C-Engine Database:**

```bash
ansible-playbook playbooks/seed-cengine-api.yaml --verbose
```

**Deploy Mental Care:**

```bash
ansible-playbook playbooks/deploy-caremate-service.yaml \
  --extra-vars='{ "service_name": "mental-care" }' \
  --verbose
```

**Each deployment does:**

1. Clones/updates service repository
2. Adds service block to `docker-compose.yml`
3. Builds Docker image
4. Starts service container
5. Displays service logs

**Expected duration per service:** 5-10 minutes

#### Step 29: Deploy Nginx (Final)

```bash
# Deploy Nginx with SSL enabled
ansible-playbook playbooks/setup-nginx.yaml --verbose
```

**This starts the Nginx reverse proxy** with all service routes configured.

---

### Phase 10: Jitsi Server Setup (Optional)

#### Step 30: Setup Jitsi Server

```bash
# Setup core packages
ansible-playbook playbooks/setup-core-config.yaml \
  --limit=jitsi-server \
  --verbose

# Setup Docker
ansible-playbook playbooks/setup-docker.yaml \
  --limit=jitsi-server \
  --verbose

# Install Jitsi Docker Stack
ansible-playbook playbooks/install-jitsi-docker-stack.yaml --verbose

# Configure Jitsi
ansible-playbook playbooks/configure-jitsi-docker-stack.yaml --verbose
```

**What this sets up:**

- Prosody (XMPP server)
- JVB (Video bridge)
- Jicofo (Conference focus)
- Jitsi Web (Frontend)
- Transcriber (Speech-to-text)

**Expected duration:** 20-30 minutes

---

### Phase 11: Verification

#### Step 31: Verify All Services

**Check Docker containers:**

```bash
ssh dhp@caremate-server "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
```

**Expected output:**

```
NAMES              STATUS          PORTS
nginx              Up 10 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
caremate-server    Up 15 minutes   0.0.0.0:8103->8103/tcp
cengine-api        Up 10 minutes   0.0.0.0:8003->8000/tcp
care-assistant     Up 10 minutes   0.0.0.0:3002->3002/tcp
ai-scribe          Up 10 minutes   0.0.0.0:8000->8000/tcp
mental-care        Up 10 minutes   0.0.0.0:8004->8000/tcp
neo4j              Up 20 minutes   0.0.0.0:7474->7474/tcp, 0.0.0.0:7687->7687/tcp
postgres           Up 20 minutes   0.0.0.0:5432->5432/tcp
redis              Up 20 minutes   0.0.0.0:6379->6379/tcp
chroma-server      Up 10 minutes   0.0.0.0:8001->8000/tcp
```

**Test API endpoints:**

```bash
# Test caremate-server (via Nginx)
curl https://api.fpt-healthcare.com/healthcheck

# Test Neo4j browser
curl https://api.fpt-healthcare.com/neo4j/
```

**Check service logs:**

```bash
ssh dhp@caremate-server "docker compose -f caremate-server/docker-compose.yml logs --tail 50 caremate-server"
```

#### Step 32: Verify Database Connectivity

```bash
# SSH into server
ssh dhp@caremate-server

# Connect to PostgreSQL
docker exec -it postgres psql -U medplum -d medplum

# List databases
\l

# Check tables
\dt

# Exit
\q
exit
```

---

## Running the Application

### Starting All Services

#### Start All Services (Recommended)

```bash
# SSH into caremate-server
ssh dhp@caremate-server

# Navigate to project directory
cd caremate-server

# Start all services
docker compose up -d

# Verify all services are running
docker compose ps

# Check logs
docker compose logs -f
```

#### Start Individual Services

```bash
# Start specific service
docker compose up -d <service-name>

# Examples:
docker compose up -d postgres
docker compose up -d redis
docker compose up -d caremate-server
docker compose up -d cengine-api
docker compose up -d care-assistant
docker compose up -d ai-scribe
docker compose up -d nginx
```

### Stopping Services

#### Stop All Services

```bash
# Stop all services
docker compose down

# Stop all services and remove volumes (CAUTION: deletes data)
docker compose down -v
```

#### Stop Individual Services

```bash
# Stop specific service
docker compose stop <service-name>

# Example:
docker compose stop caremate-server
```

### Restarting Services

#### Restart All Services

```bash
docker compose restart
```

#### Restart Individual Services

```bash
docker compose restart <service-name>

# Example:
docker compose restart nginx
```

### Viewing Service Status

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Docker Compose status
docker compose ps

# Detailed container info
docker inspect <container-name>
```

### Rebuilding Services

#### Rebuild After Code Changes

```bash
# Rebuild specific service
docker compose build <service-name>

# Rebuild and restart
docker compose up -d --build <service-name>

# Example: Rebuild caremate-server
docker compose build caremate-server
docker compose up -d caremate-server
```

#### Full Rebuild

```bash
# Rebuild all services
docker compose build

# Rebuild without cache
docker compose build --no-cache

# Rebuild and restart all services
docker compose up -d --build
```

---

## Debugging Guide

### Log Analysis

#### Viewing Logs

**Docker Compose logs:**

```bash
# View all logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View logs for specific service
docker compose logs <service-name>

# View last 100 lines
docker compose logs --tail 100 <service-name>

# View logs with timestamps
docker compose logs --timestamps <service-name>

# Examples:
docker compose logs -f caremate-server
docker compose logs --tail 50 cengine-api
docker compose logs --timestamps nginx
```

**Docker logs:**

```bash
# View container logs
docker logs <container-name>

# Follow logs
docker logs -f <container-name>

# View last 100 lines
docker logs --tail 100 <container-name>

# View logs since timestamp
docker logs --since 2024-01-01T00:00:00 <container-name>
```

#### Log Locations

**Service logs:**

- **caremate-server:** `docker compose logs caremate-server`
- **cengine-api:** `docker compose logs cengine-api`
- **PostgreSQL:** `docker compose logs postgres`
- **Redis:** `docker compose logs redis`
- **Nginx:** `docker compose logs nginx`
- **Neo4j:** `docker compose logs neo4j`

**System logs (on server):**

```bash
# System journal
sudo journalctl -u docker

# Nginx access log
sudo tail -f /var/log/nginx/access.log

# Nginx error log
sudo tail -f /var/log/nginx/error.log
```

### Common Issues & Solutions

#### Issue 1: Service Won't Start

**Symptoms:**

- Container exits immediately after starting
- `docker compose ps` shows `Exit 1` or `Exit 137`

**Debugging steps:**

```bash
# Check logs
docker compose logs <service-name>

# Check container status
docker compose ps <service-name>

# Try running container interactively
docker compose run --rm <service-name> /bin/bash

# Check environment variables
docker compose config
```

**Common causes:**

- Missing environment variables
- Database connection failure
- Port already in use
- Out of memory

**Solutions:**

```bash
# Verify environment file exists
ls -la .env

# Check port conflicts
sudo netstat -tuln | grep <port>

# Check memory usage
free -h
docker stats

# Restart Docker daemon
sudo systemctl restart docker
```

#### Issue 2: Database Connection Failed

**Symptoms:**

- Services log "Connection refused" or "Connection timeout"
- PostgreSQL/Neo4j/Redis not reachable

**Debugging steps:**

```bash
# Check if database containers are running
docker compose ps postgres redis neo4j

# Check database logs
docker compose logs postgres
docker compose logs neo4j
docker compose logs redis

# Test database connectivity
docker exec -it postgres pg_isready -U medplum

# Test PostgreSQL connection
docker exec -it postgres psql -U medplum -d medplum -c "SELECT version();"

# Test Redis connection
docker exec -it redis redis-cli ping

# Test Neo4j connection
curl http://localhost:7474
```

**Common causes:**

- Database container not running
- Incorrect credentials
- Database not initialized

**Solutions:**

```bash
# Restart database containers
docker compose restart postgres redis neo4j

# Check database environment variables
docker compose exec caremate-server env | grep DATABASE

# Reinitialize database (CAUTION: deletes data)
docker compose down -v
docker compose up -d postgres
docker compose logs -f postgres
```

#### Issue 3: Nginx 502 Bad Gateway

**Symptoms:**

- API requests return 502 error
- Nginx error log shows "connect() failed"

**Debugging steps:**

```bash
# Check Nginx logs
docker compose logs nginx | grep error

# Check backend service status
docker compose ps caremate-server cengine-api care-assistant

# Test backend directly (bypass Nginx)
curl http://localhost:8103/healthcheck
curl http://localhost:8003/healthcheck

# Check Nginx configuration
docker compose exec nginx nginx -t

# Reload Nginx configuration
docker compose exec nginx nginx -s reload
```

**Common causes:**

- Backend service not running
- Backend service crashed
- Incorrect proxy configuration

**Solutions:**

```bash
# Restart backend service
docker compose restart caremate-server

# Check backend logs
docker compose logs --tail 100 caremate-server

# Restart Nginx
docker compose restart nginx
```

#### Issue 4: SSL Certificate Issues

**Symptoms:**

- Browser shows "Certificate expired"
- `curl` fails with SSL error

**Debugging steps:**

```bash
# Check certificate expiration
ssh dhp@caremate-server "sudo certbot certificates"

# Test SSL endpoint
curl -vvv https://api.fpt-healthcare.com

# Check Nginx SSL configuration
ssh dhp@caremate-server "sudo cat /etc/nginx/sites-enabled/default | grep ssl"
```

**Solutions:**

```bash
# Renew certificate manually
ssh dhp@caremate-server "sudo certbot renew"

# Force renew
ssh dhp@caremate-server "sudo certbot renew --force-renewal"

# Restart Nginx
ssh dhp@caremate-server "docker compose restart nginx"
```

#### Issue 5: Out of Disk Space

**Symptoms:**

- Deployments fail
- Docker build fails
- Logs show "no space left on device"

**Debugging steps:**

```bash
# Check disk usage
ssh dhp@caremate-server "df -h"

# Check Docker disk usage
ssh dhp@caremate-server "docker system df"

# Find large files
ssh dhp@caremate-server "du -h / | sort -rh | head -20"
```

**Solutions:**

```bash
# Clean up Docker
ssh dhp@caremate-server "docker system prune -a"

# Remove unused volumes
ssh dhp@caremate-server "docker volume prune"

# Remove old images
ssh dhp@caremate-server "docker image prune -a"

# Clean up logs
ssh dhp@caremate-server "sudo journalctl --vacuum-time=7d"
```

#### Issue 6: High Memory Usage

**Symptoms:**

- Server becomes slow
- OOM (Out of Memory) errors in logs
- Containers being killed

**Debugging steps:**

```bash
# Check memory usage
ssh dhp@caremate-server "free -h"

# Check container memory usage
ssh dhp@caremate-server "docker stats --no-stream"

# Identify memory-hungry processes
ssh dhp@caremate-server "ps aux --sort=-%mem | head -20"
```

**Solutions:**

```bash
# Restart high-memory containers
docker compose restart <service-name>

# Add memory limits to docker-compose.yml
# services:
#   caremate-server:
#     mem_limit: 2g

# Restart Docker daemon
sudo systemctl restart docker
```

### Debugging Individual Services

#### Caremate Server (Node.js)

**Check logs:**

```bash
docker compose logs -f caremate-server
```

**Access container shell:**

```bash
docker compose exec caremate-server /bin/bash
```

**Common debugging commands:**

```bash
# Check Node.js version
node --version

# Check npm version
npm --version

# Check environment variables
env | grep -E "POSTGRES|REDIS|PORT"

# Test database connection
node -e "console.log(process.env.POSTGRES_USER)"
```

**Debug TypeScript build issues:**

```bash
# SSH into server
ssh dhp@caremate-server
cd caremate-server

# Rebuild TypeScript
npm run build

# Check for TypeScript errors
npx tsc --noEmit
```

#### C-Engine API (Python/FastAPI)

**Check logs:**

```bash
docker compose logs -f cengine-api
```

**Access container shell:**

```bash
docker compose exec cengine-api /bin/bash
```

**Common debugging commands:**

```bash
# Check Python version
python --version

# Check Poetry version
poetry --version

# Test database connection
poetry run python -c "import psycopg2; print('PostgreSQL driver OK')"

# Run migrations
poetry run alembic upgrade head

# Run seed script
poetry run python scripts/insert_sample_data.py
```

**Debug API issues:**

```bash
# Test API locally
curl http://localhost:8003/docs  # FastAPI docs

# Check Uvicorn logs
docker compose logs cengine-api | grep uvicorn
```

#### PostgreSQL Database

**Access database:**

```bash
# Connect to PostgreSQL
docker exec -it postgres psql -U medplum -d medplum
```

**Common SQL commands:**

```sql
-- List databases
\l

-- Connect to database
\c medplum

-- List tables
\dt

-- Describe table
\d tablename

-- Check table size
SELECT pg_size_pretty(pg_total_relation_size('tablename'));

-- Check active connections
SELECT * FROM pg_stat_activity;

-- Kill idle connections
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle';
```

**Backup database:**

```bash
# Backup specific database
docker exec postgres pg_dump -U medplum medplum > medplum_backup.sql

# Restore database
cat medplum_backup.sql | docker exec -i postgres psql -U medplum -d medplum
```

#### Neo4j Graph Database

**Access Neo4j browser:**

- URL: `https://api.fpt-healthcare.com/neo4j/`
- Username: `neo4j`
- Password: (from vault)

**Access Neo4j shell:**

```bash
# Cypher shell
docker exec -it neo4j cypher-shell -u neo4j -p <password>
```

**Common Cypher commands:**

```cypher
// Show all node labels
CALL db.labels();

// Count nodes
MATCH (n) RETURN count(n);

// Show sample nodes
MATCH (n) RETURN n LIMIT 10;

// Clear all data (CAUTION)
MATCH (n) DETACH DELETE n;
```

#### Redis Cache

**Access Redis CLI:**

```bash
docker exec -it redis redis-cli
```

**Common Redis commands:**

```redis
# Ping
PING

# List all keys
KEYS *

# Get key value
GET keyname

# Delete key
DEL keyname

# Flush all data (CAUTION)
FLUSHALL

# Get Redis info
INFO

# Monitor commands
MONITOR
```

### Performance Debugging

#### CPU Profiling

```bash
# Check CPU usage
ssh dhp@caremate-server "top -b -n 1"

# Check Docker container CPU usage
ssh dhp@caremate-server "docker stats --no-stream"

# Identify CPU-intensive processes
ssh dhp@caremate-server "ps aux --sort=-%cpu | head -10"
```

#### Memory Profiling

```bash
# Check memory usage
ssh dhp@caremate-server "free -m"

# Check swap usage
ssh dhp@caremate-server "swapon --show"

# Docker container memory usage
ssh dhp@caremate-server "docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}'"
```

#### Network Debugging

```bash
# Check open ports
ssh dhp@caremate-server "sudo netstat -tuln"

# Check active connections
ssh dhp@caremate-server "sudo netstat -an | grep ESTABLISHED"

# Test port accessibility
nc -zv caremate-server 8103

# Trace route
traceroute api.fpt-healthcare.com
```

---

## Modifying Existing Modules

### Working with Caremate Server (Main Backend)

#### Repository Location

- **GitHub:** `nguyen2v/caremate`
- **Server Path:** `/home/dhp/caremate-server`

#### Development Workflow

**1. SSH into server:**

```bash
ssh dhp@caremate-server
cd caremate-server
```

**2. Create feature branch:**

```bash
git checkout -b feature/your-feature-name
```

**3. Make code changes:**

```bash
# Edit files using vim/nano
vim src/path/to/file.ts

# Or use VS Code Remote SSH
# Install "Remote - SSH" extension in VS Code
# Connect to caremate-server
```

**4. Install dependencies (if added):**

```bash
npm install <package-name>

# Or for dev dependencies
npm install --save-dev <package-name>
```

**5. Build the project:**

```bash
# Fast build (skips tests)
npm run build:fast

# Full build (includes tests)
npm run build
```

**6. Rebuild Docker image:**

```bash
# Get current Git SHA
export GITHUB_SHA=$(git rev-parse --short HEAD)

# Build Docker image
./scripts/build-docker-server.sh

# Or use Ansible
ansible-playbook /path/to/caremate-devops/playbooks/deploy-caremate-server.yaml --verbose
```

**7. Test changes:**

```bash
# Restart service
docker compose restart caremate-server

# Check logs
docker compose logs -f caremate-server

# Test API endpoint
curl http://localhost:8103/healthcheck
```

**8. Commit and push:**

```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/your-feature-name
```

#### Adding New API Endpoints

**Example: Adding `/api/v1/patients/summary`**

**1. Create route handler (`src/routes/patients.ts`):**

```typescript
import { Router } from 'express';

const router = Router();

router.get('/summary', async (req, res) => {
  try {
    // Your logic here
    const summary = await getPatientSummary(req.user.id);
    res.json({ success: true, data: summary });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
```

**2. Register route (`src/index.ts`):**

```typescript
import patientsRouter from './routes/patients';

app.use('/api/v1/patients', patientsRouter);
```

**3. Update Nginx configuration (if needed):**

```bash
# Edit Nginx config template
vim /path/to/caremate-devops/playbooks/roles/nginx-docker-helper/templates/nginx.conf.j2

# Add location block
location /api/v1/patients {
  proxy_pass http://caremate-server:8103;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
}
```

**4. Rebuild and deploy:**

```bash
npm run build:fast
./scripts/build-docker-server.sh
docker compose up -d caremate-server
```

#### Modifying Database Schema

**Using Medplum FHIR resources:**

**1. Define new resource type:**

```typescript
// src/fhir/resources/CustomResource.ts
import { Resource } from '@medplum/fhirtypes';

export interface CustomResource extends Resource {
  resourceType: 'CustomResource';
  field1: string;
  field2: number;
}
```

**2. Update database migrations (if using raw SQL):**

```sql
-- migrations/001_add_custom_table.sql
CREATE TABLE custom_table (
  id UUID PRIMARY KEY,
  field1 VARCHAR(255),
  field2 INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**3. Run migration:**

```bash
# SSH into server
ssh dhp@caremate-server

# Connect to database
docker exec -it postgres psql -U medplum -d medplum

# Run migration
\i /path/to/migration.sql
```

---

### Working with C-Engine API (Python/FastAPI)

#### Repository Location

- **GitHub:** `nguyen2v/cengine-api`
- **Server Path:** `/home/dhp/cengine-api`

#### Development Workflow

**1. SSH into server:**

```bash
ssh dhp@caremate-server
cd cengine-api
```

**2. Create virtual environment (local development):**

```bash
# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Install dependencies
poetry install
```

**3. Make code changes:**

```bash
vim app/routers/your_router.py
```

**4. Add new dependencies:**

```bash
# Add package
poetry add <package-name>

# Add dev dependency
poetry add --group dev <package-name>
```

**5. Create database migration:**

```bash
# Generate migration
poetry run alembic revision --autogenerate -m "Add new table"

# Review migration
vim alembic/versions/xxxxx_add_new_table.py

# Apply migration
poetry run alembic upgrade head
```

**6. Test locally:**

```bash
# Run FastAPI dev server
poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**7. Rebuild Docker image:**

```bash
# Build image
docker compose build cengine-api

# Restart service
docker compose up -d cengine-api

# Check logs
docker compose logs -f cengine-api
```

#### Adding New Endpoints

**Example: Adding `/api/v1/reports`**

**1. Create router (`app/routers/reports.py`):**

```python
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db

router = APIRouter(prefix="/api/v1/reports", tags=["reports"])

@router.get("/")
async def get_reports(db: Session = Depends(get_db)):
    # Your logic here
    return {"message": "Reports endpoint"}

@router.post("/")
async def create_report(data: dict, db: Session = Depends(get_db)):
    # Create report logic
    return {"message": "Report created"}
```

**2. Register router (`app/main.py`):**

```python
from app.routers import reports

app.include_router(reports.router)
```

**3. Create database model (`app/models/report.py`):**

```python
from sqlalchemy import Column, Integer, String, DateTime
from app.database import Base

class Report(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    content = Column(String)
    created_at = Column(DateTime)
```

**4. Create migration:**

```bash
poetry run alembic revision --autogenerate -m "Add reports table"
poetry run alembic upgrade head
```

**5. Deploy:**

```bash
docker compose build cengine-api
docker compose up -d cengine-api
```

---

### Working with Care Assistant (Python)

#### Repository Location

- **Bitbucket:** `health-solution/caremate-assistant`
- **Server Path:** `/home/dhp/caremate-assistant`

#### Sub-Services

- **ai-scribe:** FastAPI service (port 8000)
- **care-assistant:** Python service (port 3002)

#### Development Workflow

**1. SSH and navigate:**

```bash
ssh dhp@caremate-server
cd caremate-assistant
```

**2. Modify code:**

```bash
# For ai-scribe
vim ai-scribe/app/main.py

# For care-assistant
vim care-assistant/src/assistant.py
```

**3. Rebuild specific service:**

```bash
# Rebuild ai-scribe
docker compose build ai-scribe
docker compose up -d ai-scribe

# Rebuild care-assistant
docker compose build care-assistant
docker compose up -d care-assistant
```

**4. Deploy via Ansible:**

```bash
# From your local machine
ansible-playbook playbooks/deploy-ai-scribe.yaml --verbose
ansible-playbook playbooks/deploy-care-assistant.yaml --verbose
```

---

### Adding New Microservices

#### Example: Adding a new "Patient Portal" service

**1. Create repository:**

```bash
# Create new repository on GitHub/Bitbucket
# Clone it locally
git clone git@github.com:nguyen2v/patient-portal.git
```

**2. Create Dockerfile:**

```dockerfile
# patient-portal/Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**3. Create Ansible playbook:**

```yaml
# playbooks/deploy-patient-portal.yaml
---
- name: Deploy patient portal service
  hosts: caremate-server
  roles:
    - role: git-puller
      repo: 'git@github.com:nguyen2v/patient-portal.git'
      dest: 'patient-portal'

    - role: caremate-sub-project-builder
      service_name: patient-portal
      service_port: 8005
      docker_port: 8000
```

**4. Create service template:**

```yaml
# playbooks/roles/caremate-sub-project-builder/templates/patient-portal-service-block.j2
  patient-portal:
    build:
      context: {{ project_dir }}/patient-portal
      dockerfile: Dockerfile
    container_name: patient-portal
    restart: unless-stopped
    ports:
      - "8005:8000"
    environment:
      - DATABASE_URL={{ database_url }}
    networks:
      - caremate-network
    depends_on:
      - postgres
      - redis
```

**5. Deploy new service:**

```bash
ansible-playbook playbooks/deploy-patient-portal.yaml --verbose
```

**6. Add Nginx route:**

```nginx
# Add to nginx.conf.j2
location /patient-portal {
  proxy_pass http://patient-portal:8000;
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
}
```

**7. Redeploy Nginx:**

```bash
ansible-playbook playbooks/setup-nginx.yaml --verbose
```

---

### Modifying Ansible Playbooks

#### Understanding Playbook Structure

**Typical playbook:**

```yaml
---
- name: Deploy service
  hosts: caremate-server
  roles:
    - role: git-puller
      repo: 'git@github.com:nguyen2v/repo.git'
      dest: 'service-name'

    - role: service-builder
      project_dir: '/home/dhp/service-name'
```

**Key components:**

- **hosts:** Target servers (from inventory.ini)
- **roles:** Reusable task collections
- **vars:** Variables passed to roles

#### Adding New Role

**1. Create role directory:**

```bash
mkdir -p playbooks/roles/my-new-role/tasks
mkdir -p playbooks/roles/my-new-role/templates
```

**2. Create tasks file:**

```yaml
# playbooks/roles/my-new-role/tasks/main.yaml
---
- name: Install package
  ansible.builtin.apt:
    name: my-package
    state: present

- name: Copy configuration
  ansible.builtin.template:
    src: config.j2
    dest: /etc/my-package/config.yaml
```

**3. Create template:**

```yaml
# playbooks/roles/my-new-role/templates/config.j2
# Configuration file
setting1: { { variable1 } }
setting2: { { variable2 } }
```

**4. Use role in playbook:**

```yaml
# playbooks/my-playbook.yaml
---
- name: My custom playbook
  hosts: caremate-server
  roles:
    - role: my-new-role
      variable1: 'value1'
      variable2: 'value2'
```

**5. Run playbook:**

```bash
ansible-playbook playbooks/my-playbook.yaml --verbose
```

---

### Modifying Terraform Infrastructure

#### Adding New Compute Instance

**1. Edit servers.tf:**

```hcl
# beaming-key-466311-v1/servers.tf

module "new_server" {
  source = "../modules/fhs-instance-ubuntu"

  name               = "new-server"
  project_id         = local.project_id
  zone               = local.zone
  machine_type       = "e2-medium"
  disk_size_gb       = 50
  image              = local.ubuntu_image

  tags = ["http-server", "https-server"]
}
```

**2. Add firewall rules:**

```hcl
# modules/fhs-instance-ubuntu/firewall.tf

resource "google_compute_firewall" "new_server_allow_http" {
  name    = "new-server-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
```

**3. Plan and apply:**

```bash
terraform -chdir=beaming-key-466311-v1 plan
terraform -chdir=beaming-key-466311-v1 apply
```

#### Changing Machine Type

**1. Edit locals.tf:**

```hcl
# beaming-key-466311-v1/locals.tf

locals {
  caremate_machine_type = "e2-standard-4"  # Upgraded from e2-standard-2
}
```

**2. Apply changes:**

```bash
terraform -chdir=beaming-key-466311-v1 plan
terraform -chdir=beaming-key-466311-v1 apply
```

**Note:** This will require stopping and restarting the instance.

---

## Security & Best Practices

### Secrets Management

#### Using Ansible Vault

**Encrypt file:**

```bash
ansible-vault encrypt playbooks/group_vars/all/vault.yml
```

**Edit encrypted file:**

```bash
ansible-vault edit playbooks/group_vars/all/vault.yml
```

**View encrypted file:**

```bash
ansible-vault view playbooks/group_vars/all/vault.yml
```

**Change vault password:**

```bash
ansible-vault rekey playbooks/group_vars/all/vault.yml
```

#### Environment Variables

**Never commit these files:**

- `.env`
- `caremate.config.json`
- `vault.yml` (always keep encrypted)
- SSH private keys
- Service account JSON files

**Verify .gitignore:**

```bash
cat .gitignore | grep -E ".env|vault|key"
```

### Firewall Configuration

#### GCP Firewall Rules

**View current rules:**

```bash
gcloud compute firewall-rules list
```

**Add new rule:**

```bash
gcloud compute firewall-rules create allow-custom-port \
  --allow tcp:9000 \
  --source-ranges 0.0.0.0/0 \
  --target-tags http-server
```

**Delete rule:**

```bash
gcloud compute firewall-rules delete allow-custom-port
```

#### Server-level Firewall (UFW)

```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status
```

### SSL/TLS Certificate Renewal

**Automatic renewal:**

```bash
# Certbot sets up automatic renewal via cron/systemd timer
sudo certbot renew --dry-run
```

**Manual renewal:**

```bash
sudo certbot renew
sudo systemctl reload nginx
```

**Check certificate expiration:**

```bash
sudo certbot certificates
```

### Backup & Recovery

#### Database Backups

**PostgreSQL backup:**

```bash
# Manual backup
docker exec postgres pg_dumpall -U medplum > /backup/postgres_$(date +%Y%m%d).sql

# Automated backup script
cat > /home/dhp/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/dhp/backups"
DATE=$(date +%Y%m%d_%H%M%S)
docker exec postgres pg_dumpall -U medplum | gzip > ${BACKUP_DIR}/postgres_${DATE}.sql.gz
find ${BACKUP_DIR} -name "postgres_*.sql.gz" -mtime +7 -delete
EOF

chmod +x /home/dhp/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /home/dhp/backup.sh
```

**Neo4j backup:**

```bash
docker exec neo4j neo4j-admin dump --to=/backup/neo4j_$(date +%Y%m%d).dump
```

#### VM Snapshots

**Create snapshot:**

```bash
./scripts/create-snapshot.sh caremate-server
./scripts/create-snapshot.sh jitsi-server
```

**List snapshots:**

```bash
gcloud compute snapshots list
```

**Restore from snapshot:**

```bash
# Create new disk from snapshot
gcloud compute disks create restored-disk \
  --source-snapshot=caremate-server-snapshot-20240101 \
  --zone=asia-southeast1-a

# Create instance from disk
gcloud compute instances create restored-instance \
  --disk=name=restored-disk,boot=yes \
  --zone=asia-southeast1-a
```

### Monitoring & Alerts

#### Resource Monitoring

**Check server resources:**

```bash
# CPU, Memory, Disk
ssh dhp@caremate-server "htop"

# Docker stats
ssh dhp@caremate-server "docker stats"

# Disk usage
ssh dhp@caremate-server "df -h"
```

#### Log Monitoring

**Centralized logging (optional):**

```bash
# Install Loki or ELK stack for centralized logging
# Or use GCP Cloud Logging
gcloud logging read "resource.type=gce_instance" --limit 50
```

### Security Hardening

#### SSH Hardening

```bash
# Disable password authentication
sudo vim /etc/ssh/sshd_config
# Set: PasswordAuthentication no
# Set: PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

#### Docker Security

```bash
# Run containers as non-root
# Add to Dockerfile:
USER node  # or other non-root user

# Enable Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Scan images for vulnerabilities
docker scan caremate-server:latest
```

#### Database Security

**PostgreSQL:**

```sql
-- Create read-only user
CREATE USER readonly WITH PASSWORD 'password';
GRANT CONNECT ON DATABASE medplum TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
```

---

## Troubleshooting

### Quick Diagnosis Commands

```bash
# Check all services
ssh dhp@caremate-server "docker compose ps"

# Check logs for errors
ssh dhp@caremate-server "docker compose logs | grep -i error"

# Check resource usage
ssh dhp@caremate-server "docker stats --no-stream"

# Check network connectivity
ssh dhp@caremate-server "docker network inspect caremate-network"

# Test database connectivity
ssh dhp@caremate-server "docker exec postgres pg_isready"
```

### Emergency Procedures

#### Service is Down

```bash
# 1. Check container status
docker compose ps

# 2. Check logs
docker compose logs --tail 100 <service>

# 3. Restart service
docker compose restart <service>

# 4. If still failing, rebuild
docker compose build <service>
docker compose up -d <service>

# 5. Check dependencies (DB, Redis)
docker compose ps postgres redis
```

#### Database Corruption

```bash
# 1. Stop all services
docker compose down

# 2. Backup database
docker compose up -d postgres
docker exec postgres pg_dumpall -U medplum > emergency_backup.sql

# 3. Try database repair
docker exec -it postgres psql -U medplum -d medplum -c "REINDEX DATABASE medplum;"

# 4. If repair fails, restore from backup
docker exec -i postgres psql -U medplum -d medplum < backup.sql
```

#### Server Unreachable

```bash
# 1. Check instance status
gcloud compute instances list

# 2. Start instance if stopped
gcloud compute instances start caremate-server --zone=asia-southeast1-a

# 3. Check firewall rules
gcloud compute firewall-rules list

# 4. Check SSH connectivity
gcloud compute ssh dhp@caremate-server --zone=asia-southeast1-a

# 5. Check system logs
sudo journalctl -xe
```

#### Rollback Deployment

```bash
# 1. SSH into server
ssh dhp@caremate-server
cd caremate-server

# 2. Checkout previous commit
git log --oneline
git checkout <previous-commit-hash>

# 3. Rebuild
export GITHUB_SHA=$(git rev-parse --short HEAD)
./scripts/build-docker-server.sh

# 4. Restart service
docker compose up -d caremate-server
```

---

## Reference

### Important File Locations

#### On Local Machine

- **Terraform:** `/home/user/caremate-devops/beaming-key-466311-v1/`
- **Ansible Playbooks:** `/home/user/caremate-devops/playbooks/`
- **Ansible Roles:** `/home/user/caremate-devops/playbooks/roles/`
- **Documentation:** `/home/user/caremate-devops/docs/`
- **Scripts:** `/home/user/caremate-devops/scripts/`

#### On Caremate Server

- **Project Root:** `/home/dhp/caremate-server/`
- **Environment File:** `/home/dhp/caremate-server/.env`
- **Config File:** `/home/dhp/.caremate-config/caremate.config.json`
- **Docker Compose:** `/home/dhp/caremate-server/docker-compose.yml`
- **Service Repositories:**
  - `/home/dhp/cengine-api/`
  - `/home/dhp/caremate-assistant/`
  - `/home/dhp/caremate-mcp/`
  - `/home/dhp/mental-care/`

### Port Reference

| Service         | Internal Port | External Port | Protocol |
| --------------- | ------------- | ------------- | -------- |
| PostgreSQL      | 5432          | 5432          | TCP      |
| Redis           | 6379          | 6379          | TCP      |
| Neo4j HTTP      | 7474          | 7474          | TCP      |
| Neo4j Bolt      | 7687          | 7687          | TCP      |
| Nginx HTTP      | 80            | 80            | TCP      |
| Nginx HTTPS     | 443           | 443           | TCP      |
| caremate-server | 8103          | 8103          | TCP      |
| cengine-api     | 8000          | 8003          | TCP      |
| care-assistant  | 3002          | 3002          | TCP      |
| ai-scribe       | 8000          | 8000          | TCP      |
| mental-care     | 8000          | 8004          | TCP      |
| chroma-server   | 8000          | 8001          | TCP      |
| Jitsi XMPP      | 5222          | 5222          | TCP      |
| Jitsi TURN      | 5349          | 5349          | TCP      |
| Jitsi JVB       | 10000         | 10000         | UDP      |

### Useful Commands Cheat Sheet

#### Ansible

```bash
# Run playbook
ansible-playbook playbooks/<playbook>.yaml --verbose

# Limit to specific host
ansible-playbook playbooks/<playbook>.yaml --limit=caremate-server

# Pass extra variables
ansible-playbook playbooks/<playbook>.yaml --extra-vars='{"key": "value"}'

# Check syntax
ansible-playbook playbooks/<playbook>.yaml --syntax-check

# Dry run
ansible-playbook playbooks/<playbook>.yaml --check
```

#### Docker Compose

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart service
docker compose restart <service>

# Build service
docker compose build <service>

# View logs
docker compose logs -f <service>

# Execute command in container
docker compose exec <service> <command>

# List services
docker compose ps

# Check configuration
docker compose config
```

#### Git

```bash
# Clone repository
git clone <repo-url>

# Create branch
git checkout -b <branch-name>

# Commit changes
git add .
git commit -m "message"

# Push changes
git push origin <branch-name>

# Pull updates
git pull origin <branch-name>

# View commit history
git log --oneline
```

#### GCloud

```bash
# List instances
gcloud compute instances list

# SSH into instance
gcloud compute ssh <instance-name> --zone=<zone>

# Start instance
gcloud compute instances start <instance-name> --zone=<zone>

# Stop instance
gcloud compute instances stop <instance-name> --zone=<zone>

# Create snapshot
gcloud compute disks snapshot <disk-name> --zone=<zone>
```

### Common Environment Variables

```bash
# caremate-server
POSTGRES_USER=medplum
POSTGRES_PASSWORD=<from-vault>
CONFIG_DIR=/home/dhp/.caremate-config

# cengine-api
ALEMBIC_DATABASE_URL=postgresql://medplum:<password>@postgres:5432/cengine_api
CENGINE_SECRET_KEY=<from-vault>

# care-assistant
OPENAI_API_KEY=<from-vault>
NEO4J_PASSWORD=<from-vault>
UVICORN_HOST=0.0.0.0
UVICORN_PORT=8000

# ai-scribe
CHROMA_API_KEY=<from-vault>
```

### Support & Documentation

#### Official Documentation

- **Terraform:** https://www.terraform.io/docs
- **Ansible:** https://docs.ansible.com
- **Docker:** https://docs.docker.com
- **Docker Compose:** https://docs.docker.com/compose
- **GCP:** https://cloud.google.com/docs

#### Project Documentation

- Main README: `/docs/README.org`
- Setup Google Cloud: `/docs/setup-google-cloud.org`
- Setup Infrastructure: `/docs/setup-infrastructure.org`
- Setup Caremate Server: `/docs/setup-caremate-server.org`

---

**Document Maintained By:** DevOps Team
**For Issues/Questions:** Contact project maintainers
**Last Review Date:** 2025-11-16
