terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.2"
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

resource "proxmox_virtual_environment_file" "ubuntu_jammy_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "tom"

  source_file {
    path      = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    file_name = "ubuntu-cloud-jammy-amd64.img"
    checksum  = "7d776e3a287d5833fd9b68eb78094709ad4cf1e536f4802399cbd7da526ffc1d"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_jammy_template" {
  depends_on = [
    proxmox_virtual_environment_file.ubuntu_jammy_cloud_image
  ]

  name = "ubuntu-jammy"

  node_name = "tom"
  vm_id     = 92122

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
    file_id      = proxmox_virtual_environment_file.ubuntu_jammy_cloud_image.id
    interface    = "virtio0"
    size         = 16
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
  }
}
