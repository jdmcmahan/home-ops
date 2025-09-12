terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.1"
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

variable "siderolink_api" {
  type      = string
  sensitive = true
}

variable "talos_events_sink" {
  type = string
}

variable "talos_logging_kernel" {
  type = string
}

variable "talos_version_tag" {
  type    = string
  default = "v1.6.1"
}

variable "dnsmasq_version_tag" {
  type    = string
  default = "v0.5.0"
}

variable "matchbox_version_tag" {
  type    = string
  default = "v0.10.0"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "tom"

  source_raw {
    data = templatefile("${path.module}/cloud-init.cloud_config.tftpl", {
      siderolink_api       = var.siderolink_api,
      talos_events_sink    = var.talos_events_sink,
      talos_logging_kernel = var.talos_logging_kernel,
      talos_version_tag    = var.talos_version_tag,
      dnsmasq_version_tag  = var.dnsmasq_version_tag,
      matchbox_version_tag = var.matchbox_version_tag
    })

    file_name = "cloud_init_sidero_omni_pxe.yml"
  }
}

resource "proxmox_virtual_environment_vm" "sidero-omni-pxe-vm" {
  depends_on = [
    proxmox_virtual_environment_file.cloud_config
  ]

  name = "sidero-omni-pxe"

  node_name = "tom"
  vm_id     = 793

  clone {
    vm_id = 90639
  }

  agent {
    enabled = true
  }

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

  network_device {
    model       = "virtio"
    bridge      = "vmbr0"
    vlan_id     = 8
    mac_address = "72:28:72:d6:e0:fc"
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }
}
