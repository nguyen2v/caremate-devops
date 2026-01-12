resource "linode_placement_group" "caremate" {
  label                = "${local.namespace}-placement-group"
  placement_group_type = "anti_affinity:local"
  region               = local.region
}
