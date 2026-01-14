# Setup Jitsi Server

## Add jitsi-server IP to /etc/hosts

- Add jitsi-server IP to your =/etc/hosts=

```conf
# google cloud
34.142.157.137 jitsi-server

# linode cloud
104.64.205.66   linode-jitsi-server
```

## Verify ssh connection

### Google

```bash
ssh dhp@jitsi-server
```

### Linode

```bash
ssh root@linode-jitsi-server
```

## Issue HTTPS Certificate

### Configure DNS

- Add jitsi-server IP to `https://domain.tenten.vn/ApiDnsSetting` DNS config

| Type     | Host | Value         | TTL       |
| -------- | ---- | ------------- | --------- |
| A Record | meet | 104.64.205.66 | Automatic |

- Wait for DNS propagation

  ```bash
  dig +short meet.fpt-healthcare.com
  ```

### Configure ansible variables

- Edit `playbooks/host_vars/jitsi-server.yaml`
- Update `host_ip` to match jitsi-server IP

```yaml
host_ip: 104.64.205.66
```

## Set TARGET_SERVER

```bash
export TARGET_SERVER=linode-jitsi-server
```

## Setup core config

```bash
ansible-playbook -v playbooks/setup-core-config.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Setup Docker

```bash
ansible-playbook -v playbooks/setup-docker.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Setup SSH key

```bash
ansible-playbook playbooks/setup-ssh-key.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Install Jitsi docker stack

```bash
ansible-playbook -v playbooks/install-jitsi-docker-stack.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Setup Build Jitsi docker

```bash
ansible-playbook -v playbooks/setup-build-jitsi-docker.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Build Jitsi web docker

```bash
ansible-playbook -v playbooks/build-jitsi-web-docker.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Build Jitsi Jigasi docker

```bash
ansible-playbook -v playbooks/build-jitsi-jigasi-docker.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```

## Configure Jitsi docker stack

```bash
ansible-playbook -v playbooks/configure-jitsi-docker-stack.yaml \
  --limit=${TARGET_SERVER} \
  --verbose
```
