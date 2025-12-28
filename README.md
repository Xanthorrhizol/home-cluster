# Home Cluster builder w/ KVM

## Objectives

- Deploy a home cluster with KVM
  - with 3 control-plane nodes
  - with 2 worker nodes
- Pass GPU into the cluster

## Directory Structure

- `00_prepare.sh`: prepare the environment
- `01_deploy-kvm.sh`: deploy KVMs in once
- `02_bootstrap.sh`: bootstrap the VMs
- `03_init-proxy-and-dns.sh`: init proxy and dns to init cluster(there is a temporal dns setting)
- `04_init-cluster.sh`: init the cluster
- `05_update-dns.sh`: update the dns to remove temporal dns setting
- `06_deploy-cni.sh`: deploy cni(cilium)
- `07_gpu-passthrough.sh`: pass GPU into the cluster *but you have a lot of preparations*
- `apps`: apps in the cluster
- `CLUSTER.md`: the document of the cluster info of mine
- `env`: settings of the cluster
- `nat-custom.xml`: kvm nat interface creation
- `utils`: util scripts

## Usage

1. Run each scripts step by step from `00_prepare.sh` to `06_deploy-cni.sh`.
2. If you want to pass GPU into the cluster, follow it.
  - Prepare the environment below(GPU Passthrough preparation).
  - Fill `env` file's relational fields: GPU_NODE, GPUS_PCI_ADDRS.
  - Run`07_gpu-passthrough.sh`.

> ### GPU Passthrough preparation
>
> **BIOS Setting**
>
> - Enable `IOMMU`.
> - Enable `Above 4G Decoding`.
> - Disable `CSM`.
> - Intel: enable `VT-d`, `VT-x`
> - AMD: enable `SVM`
>
> **Get Devices' IDs**
>
> ```bash
> $ lspci -nnk
> 09:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU116 [GeForce GTX 1660 SUPER] [10de:21c4] (rev a1)
>         Subsystem: NVIDIA Corporation TU116 [GeForce GTX 1660 SUPER] [10de:21c4]
> 09:00.1 Audio device [0403]: NVIDIA Corporation TU116 High Definition Audio Controller [10de:1aeb] (rev a1)
>         Subsystem: NVIDIA Corporation Device [10de:21c4]
> ```
> Depending on the GPU, additional PCI functions (USB / UCSI) may exist and must be included if they are in the same IOMMU group and caught by vfio-pci kernel driver.
>
> - Video
>   - PCI address: `09:00.0`
>     - Bus: `09`
>     - Device: `00`
>     - Function: `0`
>     - Domain: `0000`
>   - PCI ID:`10de:21c4`
>     - Vendor ID: `10de`
>     - Device ID: `21c4`
> - Audio
>   - PCI address: `09:00.1`
>     - Bus: `09`
>     - Device: `00`
>     - Function: `1`
>     - Domain: `0000`
>   - PCI ID:`10de:1aeb`
>     - Vendor ID: `10de`
>     - Device ID: `1aeb`
>
> **Kernel Setting(systemd bootloader)**
>
> - Add below into `options` line in `/boot/loader/entries/*.conf`.
>   - Intel
>     - `intel_iommu=on iommu=pt vfio-pci.ids=10de:21c4,10de:1aeb`
>   - AMD
>     - `amd_iommu=on iommu=pt vfio-pci.ids=10de:21c4,10de:1aeb`
> - Reboot
> 
> **Kernel Setting(grub)**
>
> - Add below into `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`.
>   - Intel
>     - `intel_iommu=on iommu=pt vfio-pci.ids=10de:21c4,10de:1aeb`
>   - AMD
>     - `amd_iommu=on iommu=pt vfio-pci.ids=10de:21c4,10de:1aeb`
> - `update-grub`(Debian/Ubuntu), `grub2-mkconfig -o /boot/grub2/grub.cfg`(Fedora)
>
> **Check if GPU devices are caught by vfio-pci kernel driver and in the independent group**
>
> ```bash
> for d in /sys/kernel/iommu_groups/*/devices/*; do
>   echo "$(basename $(dirname $d)) : $(lspci -nn -s ${d##*/})"
> done
> ```
> - You should find `vfio-pci` in `Kernel driver in use:`
