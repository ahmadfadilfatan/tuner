# ADR-0001: Use Ansible over shell scripts for configuration management

- **Status:** Accepted
- **Date:** 2026-10-03
- **Deciders:** Ahmad Fadil Fatan

## Context

**tuner** needs to configure Linux servers reproducibly: install packages,
configure services, and deploy config files. The most obvious alternative is a
set of shell scripts — but those have well-known drawbacks at scale.

## Decision

Use **Ansible** as the configuration management tool.

## Consequences

### Positive
- **Idempotent** — running the same playbook twice changes nothing
- **Declarative** — describe desired state, not the steps to reach it
- **Cross-distro** — one role works on Debian and RedHat families
- **Agentless** — no daemon on managed hosts; just SSH + Python
- **Modular** — roles package tasks, defaults, handlers, and templates together
- **Testable** — can run against containers in CI without any cloud
- **Lintable** — `ansible-lint` enforces best practices automatically

### Negative
- Slower than raw shell for simple tasks (Python overhead)
- YAML indentation errors are common and sometimes cryptic
- Python is required on managed nodes
- Large inventories need thought about performance

### Neutral
- Uses Jinja2 for templating — another syntax to learn

## Alternatives Considered

- **Shell scripts:** Not idempotent without careful `if` checks. No structured
  error handling. No built-in reporting. Fine for one-offs, painful at scale.
- **Puppet:** Powerful but requires an agent and a Puppet master. Overkill for
  a small number of hosts.
- **Chef:** Agent-based, Ruby DSL. Steeper learning curve.
- **SaltStack:** Very fast, but agent-based by default and more complex to
  set up for small projects.
- **NixOS:** Excellent but requires adopting NixOS — not viable for existing
  Linux hosts.

## References

- https://docs.ansible.com/
- https://ansible-lint.readthedocs.io/
- https://github.com/geerlingguy/docker-ubuntu2204-ansible
