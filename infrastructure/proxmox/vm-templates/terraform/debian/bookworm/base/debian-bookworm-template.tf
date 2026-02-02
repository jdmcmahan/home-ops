terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.94.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true

  ssh {
    username = var.proxmox_ssh_username
    password = var.proxmox_ssh_password
    agent    = true
  }
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_ssh_username" {
  type    = string
  default = "root"
}

variable "proxmox_ssh_password" {
  type      = string
  sensitive = true
}

resource "proxmox_virtual_environment_file" "debian_bookworm_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "tom"

  source_file {
    path      = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    file_name = "debian-cloud-bookworm-amd64.img"
  }
}

resource "proxmox_virtual_environment_vm" "debian_bookworm_template" {
  depends_on = [
    proxmox_virtual_environment_file.debian_bookworm_cloud_image
  ]

  name = "debian-bookworm"

  node_name = "tom"
  vm_id     = 90412

  template = true

  operating_system {
    type = "l26"
  }

  cpu {
    sockets = 1
    cores   = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.debian_bookworm_cloud_image.id
    interface    = "virtio0"
    size         = 16
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
  }
}
