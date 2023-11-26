# Bootstrapping Bare Metal Nodes with Matchbox

This directory contains the necessary components to [provision bare metal nodes for Sidero Omni](https://omni.siderolabs.com/docs/how-to-guides/how-to-register-a-bare-metal-machine-pxe/) over PXE/iPXE. [poseidon/matchbox](https://matchbox.psdn.io/) provides the iPXE endpoint while [poseidon/dnsmasq](https://matchbox.psdn.io/network-setup/) serves basic proxy-DHCP/TFTP/DNS capabilities.

The `pxe.sh` script (and all related configurations in this directory) assumes the host IP address is `192.168.8.254`. It also references version `1.5.5` of the [Sidero boot assets (initramfs/vmlinuz)](https://github.com/siderolabs/talos/releases).

> `todo:` IaC

To start serving PXE/iPXE functionality to the network:
1. Create a VM with an IP address of `192.168.8.254`
2. Install Docker
3. Add values for `siderolink.api`, `talos.events.sink`, and `talos.logging.kernel` in `./volumes/matchbox/var/lib/matchbox/profiles/default.json`
4. Run `./pxe.sh`

> PXE and TFTP do not need to be configured on the host router.
