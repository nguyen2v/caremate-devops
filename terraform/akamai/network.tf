resource "linode_vpc" "caremate" {
  description = "Caremate VPC"
  label       = "${local.namespace}-vpc"
  region      = local.region
}

resource "linode_vpc_subnet" "public" {
  ipv4   = local.public_subnet_cidr
  label  = "${local.namespace}-public-subnet"
  vpc_id = linode_vpc.caremate.id
}

resource "linode_vpc_subnet" "private" {
  ipv4   = local.private_subnet_cidr
  label  = "${local.namespace}-private-subnet"
  vpc_id = linode_vpc.caremate.id
}
