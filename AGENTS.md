# AGENTS.md - Caremate DevOps Repository Guide

AI coding agent guide for Infrastructure-as-Code repository (Terraform + Ansible + Bash).

## Repository Overview

Infrastructure for Caremate healthcare platform:
- **Terraform**: GCP and Akamai/Linode infrastructure provisioning
- **Ansible**: Server configuration and deployment (26 custom roles)
- **Bash**: Operational scripts (snapshots, backups)

## Build/Lint/Test Commands

### Terraform

```bash
# Initialize (required before first use)
terraform -chdir=terraform/caremate-gcp init
terraform -chdir=terraform/akamai init

# Validate configuration
terraform -chdir=terraform/caremate-gcp validate
terraform -chdir=terraform/akamai validate

# Plan changes (dry-run before applying)
terraform -chdir=terraform/caremate-gcp plan
terraform -chdir=terraform/akamai plan

# Apply changes
terraform -chdir=terraform/caremate-gcp apply
terraform -chdir=terraform/akamai apply

# Format files (run before committing)
terraform fmt -recursive terraform/
```

### Ansible

```bash
# Syntax check
ansible-playbook playbooks/setup-caremate-project.yaml --syntax-check

# Dry-run (check mode - no changes applied)
ansible-playbook playbooks/setup-caremate-project.yaml --check

# Run playbook
ansible-playbook playbooks/setup-caremate-project.yaml

# Run on specific host
ansible-playbook playbooks/setup-caremate-project.yaml --limit caremate-server

# List inventory
ansible-inventory --list
```

### Scripts

```bash
# Create server snapshot
./scripts/create-snapshot.sh caremate-server
./scripts/create-snapshot.sh jitsi-server

# List snapshots
gcloud compute snapshots list
```

### No Automated Tests

Validation through:
- `terraform validate` (syntax checking)
- `ansible-playbook --syntax-check` (syntax checking)
- `terraform plan` / `ansible-playbook --check` (dry-run execution)

## Code Style Guidelines

### Terraform

**File Organization:**
- One resource type per file: `network.tf`, `cloud-sql.tf`, `storage.tf`
- Standard files: `versions.tf`, `variables.tf`, `outputs.tf`, `locals.tf`, `backend.tf`

**Naming:**
- Resources: kebab-case with namespace prefix → `resource "linode_instance" "caremate-server"`
- Variables/Locals: snake_case → `variable "project_id"`, `locals { namespace = "caremate" }`

**Style:**
- 2-space indentation
- Run `terraform fmt -recursive` before committing
- Always define variable `type` and `description`
- Pin module versions with `~>` → `version = "~> 9.2.0"`
- Add block comments explaining purpose at top of files

### Ansible

**File Organization:**
- Playbooks: `playbooks/*.yaml`
- Roles: `playbooks/roles/*`
- Group vars: `playbooks/group_vars/`
- Sensitive data: `vault.yml` files (encrypted, password in `~/.vault_pass.txt`)

**Naming:**
- Playbooks/Roles: kebab-case → `setup-caremate-project.yaml`, `nginx-docker-helper`
- Variables: snake_case → `project_name`, `domain_name`
- Tasks: descriptive names with spaces → `"Install Docker Engine and containerd"`

**YAML Style:**
- Use `.yaml` extension (not `.yml`)
- 2-space indentation
- Start with `---`
- Quote strings with variables → `'{{ project_name }}'`
- Use `ansible.builtin.*` for built-in modules
- Add `changed_when: false` for read-only commands
- Register outputs → `register: git_status`

### Bash Scripts

**Structure:**
```bash
#!/bin/bash
set -xe  # Exit on error, print commands

VARIABLE_NAME=$1

# Validate inputs
case "${VARIABLE_NAME}" in
  expected-value-1 | expected-value-2)
    echo "Valid input"
    ;;
  *)
    echo "Usage: ./script.sh VARIABLE_NAME"
    exit 1
    ;;
esac

# Main logic
```

**Conventions:**
- Always include shebang: `#!/bin/bash`
- Use `set -e` to exit on error
- UPPER_CASE for script variables
- kebab-case for filenames

## Directory Structure

```
.
├── terraform/
│   ├── caremate-gcp/      # GCP resources (VPC, GKE, Cloud SQL, Redis, Storage)
│   ├── akamai/            # Linode instances, VPC, firewall
│   └── modules/           # Reusable modules
├── playbooks/
│   ├── roles/             # 26 custom Ansible roles
│   ├── group_vars/        # Environment variables
│   ├── host_vars/         # Host-specific variables
│   └── inventory.ini      # Server inventory
├── docs/                  # Org-mode documentation (.org files)
├── scripts/               # Operational shell scripts
└── backup/                # Backup storage (gitignored)
```

## Server Inventory

**GCloud hosts:** caremate-server, chain-server, jitsi-server, pacs-server
**Linode hosts:** linode-caremate-server, linode-chain-server, linode-jitsi-server, linode-pacs-server

## Security Requirements

**Never commit:**
- Secrets, API keys, passwords
- `.env`, `.envrc` files
- Terraform state files
- Ansible vault passwords

**Authentication:**
- GCP: `gcloud auth application-default login`
- Linode: Set `LINODE_TOKEN` environment variable
- Ansible Vault: Password file at `~/.vault_pass.txt`

## Git Workflow

- Use conventional commit messages
- Keep commits atomic and focused
- Always run validation before committing:
  - Terraform: `terraform fmt -recursive` → `terraform validate`
  - Ansible: `ansible-playbook --syntax-check`
- Test with dry-run before applying:
  - Terraform: `terraform plan`
  - Ansible: `ansible-playbook --check`
