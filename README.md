# tuner

> Idempotent configuration management for Linux servers — Ansible roles for baseline, Docker, and Nginx.

[![Ansible](https://github.com/ahmadfadilfatan/tuner/actions/workflows/ansible.yml/badge.svg)](https://github.com/ahmadfadilfatan/tuner/actions/workflows/ansible.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/ansible-%3E%3D2.15-EE0000)](https://www.ansible.com)

## Overview

**tuner** is a modular Ansible project that configures a fresh Linux server into
a ready-to-run web host. It applies three roles in order:

| Role | What it does |
|---|---|
| **common** | Baseline packages, timezone, MOTD — everything every server needs |
| **docker** | Installs Docker from the official repo, enables the service |
| **nginx** | Installs Nginx, deploys a reverse-proxy config for a local app |

The entire project is **idempotent** — running it twice changes nothing the
second time. That property is verified locally by running the playbook twice
against a disposable Ubuntu container.

This is the **third project** in a DevOps portfolio series:

| Project | Repo | Purpose |
|---|---|---|
| launchpad | `you/launchpad` | CI/CD pipeline |
| shipyard | `you/shipyard` | Terraform AWS baseline |
| **tuner** | *(this repo)* | Ansible configuration management |

## How this fits with the other projects

```
shipyard  ──►  creates the EC2 instance
                    │
                    ▼
tuner     ──►  configures that instance (Docker, Nginx)
                    │
                    ▼
launchpad ──►  provides the CI-built image that gets deployed
```

## Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Target Linux host                       │
│                                                            │
│   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐  │
│   │   common     │──►│    docker    │──►│    nginx     │  │
│   │  packages    │   │  apt + repo  │   │  reverse     │  │
│   │  timezone    │   │  service     │   │  proxy       │  │
│   │  MOTD        │   │  users       │   │  /health     │  │
│   └──────────────┘   └──────────────┘   └──────────────┘  │
│                                                            │
└────────────────────────────────────────────────────────────┘
             ▲
             │  ansible-playbook -i inventories/dev/hosts.yml
             │                    playbooks/site.yml
             │
      ┌──────────────┐
      │   Control    │
      │   machine    │
      └──────────────┘
```

## Repository Structure

```
tuner/
├── ansible.cfg                 # Ansible configuration
├── ansible.sh                  # Wrapper: run Ansible in Docker
├── requirements.yml            # Galaxy collections
├── .ansible-lint               # Lint configuration (production profile)
├── inventories/
│   └── dev/
│       └── hosts.yml           # Dev inventory (localhost)
├── playbooks/
│   └── site.yml                # Main playbook — applies all roles
├── roles/
│   ├── common/                 # Baseline packages, timezone, MOTD
│   ├── docker/                 # Docker installation + service
│   └── nginx/                  # Nginx + reverse-proxy template
└── docs/
    └── adr/
        └── 0001-use-ansible-over-shell-scripts.md
```

## Quickstart

### Prerequisites

- Docker (for the containerized control node)
- No local Ansible install required

### Run the playbook locally (against a container)

```bash
# Start a disposable Ubuntu container
MSYS_NO_PATHCONV=1 docker run -d --name tuner-test \
  -v "$(pwd)":/work -w /work \
  geerlingguy/docker-ubuntu2204-ansible:latest sleep infinity

# First run
MSYS_NO_PATHCONV=1 docker exec -it \
  -e ANSIBLE_CONFIG=/work/ansible.cfg \
  -e ANSIBLE_ROLES_PATH=/work/roles \
  -e ANSIBLE_INVENTORY=/work/inventories/dev/hosts.yml \
  tuner-test sh -c "ansible-galaxy collection install -r requirements.yml && ansible-playbook playbooks/site.yml"

# Second run (idempotency check — expect changed=0)
MSYS_NO_PATHCONV=1 docker exec -it \
  -e ANSIBLE_CONFIG=/work/ansible.cfg \
  -e ANSIBLE_ROLES_PATH=/work/roles \
  -e ANSIBLE_INVENTORY=/work/inventories/dev/hosts.yml \
  tuner-test ansible-playbook playbooks/site.yml

# Clean up
docker stop tuner-test && docker rm tuner-test
```

### Lint and syntax check

```bash
./ansible.sh --syntax-check playbooks/site.yml

# Or inside a CI-like environment:
pip install ansible ansible-lint
ansible-galaxy collection install -r requirements.yml
ansible-lint
```

## Design Principles Applied

- **Idempotent** — running twice produces `changed=0`
- **Cross-distro** — supports Debian and RedHat families
- **Modular** — one role per concern, easy to reuse
- **Testable** — runs in a container, no cloud dependency
- **Modern modules** — uses `deb822_repository`, not deprecated `apt_key`
- **Linted** — `ansible-lint` in `production` profile
- **Documented** — each role has `defaults/main.yml` listing its knobs

## Design Decisions

- [ADR-0001: Use Ansible over shell scripts](docs/adr/0001-use-ansible-over-shell-scripts.md)

## Roadmap

- [x] v1.0.0 — common, docker, nginx roles; local container testing
- [ ] v1.1.0 — Add `app` role to deploy the `launchpad` image
- [ ] v1.2.0 — Add `monitoring` role (node_exporter, Promtail)
- [ ] v1.3.0 — Molecule tests for each role
- [ ] v2.0.0 — Dynamic inventory from Terraform state (`shipyard`)

## License

[MIT](LICENSE)
