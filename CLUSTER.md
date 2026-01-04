# Home Cluster

## Cluster Info

- OS: Ubuntu 24.04
- Nodes: 3 Master, 2 Worker by KVM
- Cluster Provisioner: kubeadm
- Storage: NFS
- DNS: bind

## HW Info

- Motherboard: X570 Phantom Gaming 4
- CPU: AMD Ryzen 9 5900X (12 Core, 24 Thread)
- RAM: 64GB
- Disk: 1TB NVMe SSD + 1TB HDD

## VM Info

- GW(1): 2 vCPU, 4GB RAM, 32GB Disk, Alpine Linux 3.23
- NFS(1): 2 vCPU, 2GB RAM, 32GB Disk, Alpine Linux 3.23
- Master(3): 2 vCPU, 4GB RAM, 32GB Disk, Ubuntu 24.04
- Worker(2): 6 vCPU, 20GB RAM, 64GB Disk, Ubuntu 24.04
