# Home Cluster

![image](/assets/topology.png)

## Cluster Info

- OS: Proxmox
- Nodes: 3 Master, 2 Worker by KVM
- Cluster Provisioner: kubeadm
- Storage: NFS
- DNS: bind

### HW Info

- Motherboard: X570 Phantom Gaming 4
- CPU: AMD Ryzen 9 5900X (12 Core, 24 Thread)
- RAM: 64GB
- Disk: 1TB NVMe SSD + 1TB HDD
- Network
  - 1000 Base-T
    - Default Network
  - SFP+ (10G)
    - Directly connected with NAS Host

### VM Info

- GW(1): 2 vCPU, 4GB RAM, 32GB Disk, Alpine Linux 3.23
- NFS(1): 2 vCPU, 2GB RAM, 32GB Disk, Alpine Linux 3.23
- Master(3): 2 vCPU, 4GB RAM, 32GB Disk, Talos Linux v1.12.0
- Worker(2): 6 vCPU, 20GB RAM, 64GB Disk, Talos Linux v1.12.0

## NAS Info

- OS: Proxmox
- Disk: 4TB * 4
- RAID: 10

### HW Info

- Motherboard: B365 M AORUS ELITE
- CPU: Intel i7-9700K
- RAM: 16GB
- SSD: 500GB
- Disk: 4TB HDD * 4 with RAID10
- Network
  - 1000 Base-T
    - Default Network
  - SFP+ (10G)
    - Directly connected with Cluster Host

### VM Info

- nas(1): 2 vCPU, 12GB Ram, 32GB SSD, 4TB HDD * 4, OpenMediaVault
