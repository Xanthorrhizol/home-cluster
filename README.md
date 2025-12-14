# Home Cluster

## Cluster Info

- OS: Talos Linux 1.11.x
- Nodes: 3 Master, 2 Worker by KVM
- Cluster Provisioner: none
- Storage: NFS
- DNS: bind
- Proxy: HaProxy

## HW Info

- Motherboard: X570 Phantom Gaming 4
- CPU: AMD Ryzen 9 5900X (12 Core, 24 Thread)
- RAM: 64GB
- Disk: 1TB NVMe SSD + 1TB HDD

## VM Info

- Proxy & DNS(1): 2 vCPU, 4GB RAM, 10GB Disk, Alpine Linux 3.21
- Master(3): 2 vCPU, 4GB RAM, 10GB Disk, Talos Linux 1.11.5
- Worker(2): 6 vCPU, 20GB RAM, 32GB Disk, Talos Linux 1.11.5

## Todo

- [x] Create basic cluster
- [ ] Deploy [rustcost](https://github.com/rustcost/rustcost-core)
- [ ] Make personal NAS
  - OS: OpenMediaVault
  - Motherboard: B365 M AORUS ELITE
  - CPU: Intel i7-9700K (4 Core, 8 Thread)
  - RAM: 16GB
  - Disk: 500GB NVMe SSD + 2 x 4TB HDD
- [ ] Attach NFS provisioner into personal NAS
