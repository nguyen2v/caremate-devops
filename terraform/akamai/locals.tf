locals {
  namespace = "caremate"

  private_subnet_cidr = "10.11.0.0/24"
  public_subnet_cidr  = "10.10.0.0/24"
  region              = "sg-sin-2"

  # instance types
  g6_dedicated_2 = "g6-dedicated-2" # 2 CPU, 80 GB Storage, 4 GB RAM
  g6_dedicated_4 = "g6-dedicated-4" # 4 CPU, 160 GB Storage, 8 GB RAM
  g6_dedicated_8 = "g6-dedicated-8" # 8 CPU, 320 GB Storage, 16 GB RAM

  # default tcp_ports
  default_tcp_ports = [22, 80, 443]
}
