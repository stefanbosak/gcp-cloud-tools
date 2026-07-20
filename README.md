<div align="center">

# ☁️ GCP Cloud Tools

**GCP ecosystem CLI tools (Hardened)**

[![build_status_badge](../../actions/workflows/docker-image-native-multiplatform-pipeline.yaml/badge.svg?branch=main)](.github/workflows/docker-image-native-multiplatform-pipeline.yaml)
[![GCP](https://img.shields.io/badge/Google%20Cloud-4285F4?logo=googlecloud&logoColor=fff&style=flat-square)](https://cloud.google.com/)

</div>

---

## 📦 Latest Build

<!-- VERSION_INFO_START -->
| Component | Version |
|-----------|---------|
| **Ansible** | [`v2.21.2`](https://github.com/ansible/ansible/releases/tag/v2.21.2) |
| **cert-manager CLI** | [`v2.5.0`](https://github.com/cert-manager/cmctl/releases/tag/v2.5.0) |
| **GCP CLI** | [`576.0.0`](https://cloud.google.com/sdk/docs/release-notes) |
| **Helm** | [`v4.2.3`](https://github.com/helm/helm/releases/tag/v4.2.3) |
| **K9s** | [`v0.51.0`](https://github.com/derailed/k9s/releases/tag/v0.51.0) |
| **Kops** | [`v1.36.0`](https://github.com/kubernetes/kops/releases/tag/v1.36.0) |
| **Kubectl** | [`v1.37.0-alpha.3`](https://github.com/kubernetes/kubernetes/releases/tag/v1.37.0-alpha.3) |
| **Kustomize** | [`5.8.1`](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize/v5.8.1) |
| **SwarmCLI** | [`v1.13.0-rc1`](https://github.com/Eldara-Tech/swarmcli/releases/tag/v1.13.0-rc1) |
| **Terraform** | [`1.16.0-alpha20260715`](https://github.com/hashicorp/terraform/releases/tag/v1.16.0-alpha20260715) |
| **Terragrunt** | [`v1.1.1`](https://github.com/gruntwork-io/terragrunt/releases/tag/v1.1.1) |

> 🔄 Last updated: 2026-07-20T20:48:38+02:00 · [Build #88](https://github.com/stefanbosak/gcp-cloud-tools/actions/runs/29769434299)
<!-- VERSION_INFO_END -->

---

## 📋 Overview

This repository provides a fully automated preparation of <span style="color: #0969da;">**containerized**</span> [GCP](https://cloud.google.com/) environment using <span style="color: #1a7f37;">**Docker-in-Docker**</span> architecture.

### Covered CLI tools

| Tool | Description |
|------|-------------|
| [Ansible CLI](https://docs.ansible.com/ansible/latest/command_guide/command_line_tools.html) | <span style="color: #8250df;">Configuration management and automation</span> |
| [GCP CLI](https://cloud.google.com/sdk/gcloud) | <span style="color: #8250df;">Official GCP command-line interface</span> |
| [cert-manager CLI](https://github.com/cert-manager/cmctl/) | <span style="color: #d73a49;">cert-manager CLI</span> |
| [CNPG CLI](https://github.com/cloudnative-pg/cloudnative-pg/) | <span style="color: #d73a49;">CloudNativePG CLI</span> |
| [Docker CLI](https://docker.com) | <span style="color: #d73a49;">Container management CLI</span> |
| [HELM CLI](https://helm.sh/docs/helm/) | <span style="color: #0969da;">Kubernetes package manager</span> |
| [kops CLI](https://kops.sigs.k8s.io/) | <span style="color: #0969da;">Kubernetes cluster management</span> |
| [kubectl CLI](https://kubernetes.io/docs/reference/kubectl/) | <span style="color: #0969da;">Kubernetes command-line tool</span> |
| [k9s CLI](https://k9scli.io/) | <span style="color: #0969da;">Terminal UI for Kubernetes</span> |
| [SwarmCLI](https://github.com/Eldara-Tech/swarmcli) | <span style="color: #0969da;">Terminal UI for Docker Swarm</span> |
| [Terraform CLI](https://developer.hashicorp.com/terraform/cli) | <span style="color: #1a7f37;">Infrastructure as Code tool</span> |
| [Terragrunt CLI](https://terragrunt.gruntwork.io/) | <span style="color: #1a7f37;">Terraform wrapper for DRY configurations</span> |

> [!NOTE]
> Every script and file is reasonably well commented and relevant details can be found there.

> [!IMPORTANT]
> Check details before taking any action.

> [!CAUTION]
> User is responsible for any modification and execution of any parts from this repository.

---

## ⚡ Zero Effort Approach

GitHub Actions workflow file covers all necessary activities which are fully automated in GitHub (re-using Docker container approach as base for automation):

- <span style="color: #1a7f37;">Gathering and propagating latest available tools versions to Docker preparation process</span>
- <span style="color: #0969da;">Building Docker hardened image</span>

---

## 🐳 Docker Container Approach

Docker build wrapper script covers creation of a container built from a multistage Dockerfile using parallel execution of several builders to speed up preparation. Generated image contains all mentioned tools with pre-enabled Bash completions. Docker run wrapper simplifies application execution.

| File | Description |
|------|-------------|
| [`Dockerfile`](Dockerfile) | <span style="color: #0969da;">Recipe for preparation of Docker container</span> |
| [`.docker`](.docker) | <span style="color: #8250df;">Directory for configuration data persistency (can be mapped into container)</span> |
| [`.config`](.config) | <span style="color: #8250df;">Directory for GCP configuration data persistency (can be mapped into container)</span> |
| [`scripts`](scripts) | <span style="color: #1a7f37;">GCP helper scripts directory (can be mapped into container)</span> |

### 🏗️ Container Images

| Registry | Network Support | Pull Command |
|----------|----------------|--------------|
| [**DockerHub CR**](https://hub.docker.com/r/developmententity/gcp-cloud-tools) | <span style="color: #1a7f37;">IPv4 & IPv6</span> | `docker pull developmententity/gcp-cloud-tools:initial` |
| [**GitHub CR**](https://github.com/users/stefanbosak/packages/container/package/gcp-cloud-tools) | <span style="color: #8250df;">IPv4 only</span> | `docker pull ghcr.io/stefanbosak/gcp-cloud-tools:initial` |

---

## 🌍 GCP Environment

GCP environment can be used via gcp-cloud-tools container which is automatically generated and available within ghcr.io. The dedicated `run.sh` script pulls and runs the up-to-date container. To access GCP from within the container, run the initialization script each time after the container starts:

```bash
. scripts/set_gcp_environment.sh
```

After initialization, GCP ecosystem access works without additional authentication. Obtained tokens are stored outside the container; re-run the initialization script if tokens expire.

**Change GCP user** — edit `.config/gcloud/configurations/config_default`:

```ini
[core]
account = <name.surname@domain.tld>
```

Then re-authenticate:

```bash
gcloud auth login --update-adc --no-launch-browser
```

---

## 🏗️ IaC (Infrastructure as Code)

GCP infrastructure is incrementally covered via [Terraform](https://developer.hashicorp.com/terraform) / [OpenTofu](https://opentofu.org) code.

| Path | Description |
|------|-------------|
| [`scripts/IaC/terraform`](scripts/IaC/terraform) | <span style="color: #1a7f37;">Terraform/OpenTofu IaC files</span> |

---

## ☸️ Kubernetes Manifests

GKE resources are incrementally covered using kubectl and Helm charts.

| Path | Description |
|------|-------------|
| [`scripts/kubernetes`](scripts/kubernetes) | <span style="color: #0969da;">Kubernetes manifest files</span> |

---

<div align="center">

<span style="color: #8250df;">**Made with ❤️ for ☁️ GCP ecosystem and 🔒 security**</span>

</div>
