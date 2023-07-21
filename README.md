## 📖 Overview

This is a monorepository implementing infrastructure-as-code (IaC) and GitOps practices for my home Kubernetes cluster using tools such as [ArgoCD](https://github.com/argoproj/argo-cd) and [Renovate](https://github.com/renovatebot/renovate).

This project was largely inspired by [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) but built entirely from scratch because I hate myself. Huge thanks to the amazing [k8s@home](https://discord.gg/sTMX7Vh) community for making Kubernetes accessible to homelabbers and hobbyists like me.

## ⛵ Kubernetes

My k8s cluster is running on bare-metal Talos servers. The infrastructure is somewhat hyperconverged with nodes handling both application workloads and block storage via [Rook Ceph](https://github.com/rook/rook).

### Installation

To build the cluster, I use [Sidero Metal](https://www.sidero.dev/v0.5/getting-started) to bootstrap my bare-metal nodes over PXE. Sidero automatically provisions the nodes based on the resources defined in [/infrastructure/sidero-metal](https://github.com/jdmcmahan/home-ops/tree/main/infrastructure/sidero-metal).

### Core Components

- [cert-manager](https://github.com/cert-manager/cert-manager) - creates and manages SSL certificates for services in the cluster.
- [external-dns](https://github.com/kubernetes-sigs/external-dns) - automatically syncs DNS records from services to my local DNS provider.
- [external-secrets](https://github.com/external-secrets/external-secrets/) - creates Kubernetes secrets from 1Password via [1Password Connect](https://github.com/1Password/connect).
- [metallb](https://github.com/metallb/metallb) - provides external IP addresses and load balancing functionality for services.
- [rook-ceph](https://github.com/rook/rook) - provides distributed block storage for peristent volumes.
- [traefik](https://github.com/traefik/traefik) - exposes HTTP traffic to external clients over DNS.

## :octocat: GitOps

This repository uses [ArgoCD](https://github.com/argoproj/argo-cd) and its [`ApplicationSet`](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set) concept to deploy and manage all resources in the cluster (including itself). Installing ArgoCD and deploying the inital `ApplicationSet` (and, in turn, everything else in the cluster) is as easy as:

```bash
$ kubectl apply -k apps/management/argocd
```

This ArgoCD `ApplicationSet` is currently configured to discover all `kustomization.yaml` files at any level under the `apps/` directory. These files may reference other resources which will be applied along with the application. One advantage of this approach is that all new `kustomization.yaml` files added to this Git repository will be discovered and deployed to the cluster by ArgoCD. Conversely, removal of a resource definition in the repository will cause that resource to be uninstalled from the cluster. Such changes are automated and instantaneous thanks to GitHub's webhook capabilities.

The full `ApplicationSet` configuration is defined in [`apps/management/argocd/applications.yaml`](apps/management/argocd/applications.yaml).

[Renovate](https://github.com/renovatebot/renovate) (running as a [GitHub App](https://github.com/apps/renovate)) monitors the entire repository for application updates. These updates are automatically applied to the cluster by merging the resulting Renovate pull requests.

## 🖧 Networking

| Name                    | CIDR              |
|-------------------------|-------------------|
| Kubernetes nodes (VLAN) | `192.168.8.0/24`  |
| Kubernetes pods         | `10.244.0.0/16`   |
| Kubernetes services     | `10.96.0.0/12`    |

## 🔧 Hardware

Many of my hardware components and parts have been salvaged from a local e-waste facility or bought second-hand from upcycling communities like [r/homelabsales](https://www.reddit.com/r/homelabsales). This has resulted in a very cost-effective but capable lab thanks to federated software like Proxmox and k8s.

| Device                      | Count | CPU              | RAM   | Operating System | Purpose                                      |
|-----------------------------|-------|------------------|-------|------------------|----------------------------------------------|
| Intel NUC8i5BEH             | 1     | Intel i5-8259U   | 16 GB | Proxmox          | General-purpose VMs & containers             |
| Dell OptiPlex 7060 Micro    | 1     | Intel i5-8500T   | 16 GB | Talos            | Kubernetes control plane nodes               |
| Dell OptiPlex 7060 Micro    | 3     | Intel i5-8600T   | 32 GB | Talos            | Kubernetes worker nodes, block storage       |
| Raspberry Pi 3B             | 1     | Broadcom BCM2837 | 1 GB  | OctoPi           | Remote 3D printer monitoring & management    |
| Kobol Helios64              | 1     | Rockchip RK3399  | 4 GB  | Armbian          | NAS                                          |
| UniFi UDM-Pro               | 1     | ARM Cortex-A57   | 4 GB  | UniFi OS         | Gateway, router, NVR                         |
