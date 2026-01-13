locals {
  servers = {
    caremate = {
      label     = "${local.namespace}-server"
      type      = local.g6_dedicated_4
      tcp_ports = [7474, 7687]
    }
    jitsi = {
      label     = "jitsi-server"
      type      = local.g6_dedicated_4
      tcp_ports = [5222, 5349]
      udp_ports = [10000]
    }
  }
}

resource "linode_instance" "servers" {
  for_each = local.servers

  image  = "linode/ubuntu24.04"
  label  = each.value.label
  region = local.region
  type   = each.value.type

  authorized_keys = [
    linode_sshkey.caremate-duongtq.ssh_key,
    linode_sshkey.caremate-vietnv.ssh_key,
  ]

  placement_group_externally_managed = true

  tags = [local.namespace]
}

resource "linode_placement_group_assignment" "servers-assignment" {
  for_each = linode_instance.servers

  placement_group_id = linode_placement_group.caremate.id
  linode_id          = each.value.id
}

resource "linode_firewall" "servers-firewall" {
  for_each = linode_instance.servers

  label = "${each.value.label}-firewall"

  dynamic "inbound" {
    for_each = concat(local.default_tcp_ports, lookup(local.servers[each.key], "tcp_ports", []))

    content {
      label    = "allow-port-${inbound.value}"
      action   = "ACCEPT"
      protocol = "TCP"
      ports    = tostring(inbound.value)
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  dynamic "inbound" {
    for_each = lookup(local.servers[each.key], "udp_ports", [])

    content {
      label    = "allow-port-${inbound.value}"
      action   = "ACCEPT"
      protocol = "UDP"
      ports    = tostring(inbound.value)
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  linodes = [each.value.id]

  tags = [local.namespace]
}
