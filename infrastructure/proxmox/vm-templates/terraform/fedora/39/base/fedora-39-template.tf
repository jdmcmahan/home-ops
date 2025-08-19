terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.82.1"
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

resource "proxmox_virtual_environment_file" "fedora_39_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "tom"

  source_file {
    path      = "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
    file_name = "fedora-cloud-39-qemu-x86_64.img"
    checksum  = "ab5be5058c5c839528a7d6373934e0ce5ad6c8f80bd71ed3390032027da52f37"
  }
}

resource "proxmox_virtual_environment_vm" "fedora_39_template" {
  depends_on = [
    proxmox_virtual_environment_file.fedora_39_cloud_image
  ]

  name = "fedora-39"

  node_name = "tom"
  vm_id     = 90639

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
    file_id      = proxmox_virtual_environment_file.fedora_39_cloud_image.id
    interface    = "virtio0"
    size         = 16
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
  }
}
