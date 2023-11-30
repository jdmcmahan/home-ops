packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" {
    type = string
    default = "https://proxmox.localdomain:8006/api2/json"
}

variable "proxmox_api_token_id" {
    type = string
    default = "packer@pam!packer-token"
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

source "proxmox-iso" "ubuntu-server-jammy-docker" {
 
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true
    
    node = "tom"
    vm_id = "9001"
    vm_name = "ubuntu-server-jammy-docker"
    template_description = "Ubuntu Server 22.04 (Jammy Jellyfish) with Docker"

    iso_file = "local:iso/ubuntu-22.04-live-server-amd64.iso"
    iso_storage_pool = "local"
    unmount_iso = true

    qemu_agent = true

    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "30G"
        storage_pool = "local-lvm"
        type = "virtio"
    }

    cores = 2
    memory = 4096 

    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    }

    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]

    boot = "c"
    boot_wait = "10s"

    http_directory = "http"

    ssh_username = "donnie"
    ssh_private_key_file = "~/.ssh/homelab_id_ed25519"

    ssh_timeout = "20m"
}

build {

    name = "ubuntu-server-jammy-docker"
    sources = ["source.proxmox-iso.ubuntu-server-jammy-docker"]

    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt-get -y autoremove --purge",
            "sudo apt-get -y clean",
            "sudo apt-get -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
            "sudo systemctl enable docker.service",
            "sudo systemctl enable containerd.service"
        ]
    }
}