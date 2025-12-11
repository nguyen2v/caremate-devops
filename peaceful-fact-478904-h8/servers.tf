locals {
  servers = {
    "caremate-server" = {
      address      = "34.124.210.203"
      machine_type = local.machine_type.e2_standard_2
      snapshot     = "projects/${local.project_id}/global/snapshots/caremate-server-${local.snapshot_date}"
      region       = local.region_southeast1
      status       = local.running
      tcp_ports    = ["5432", "7474", "7687"]
      zone         = local.zone_southeast1
      ssh_keys = join("\n", [
        "dhp:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHA8rvoQGuvHwWY8vBSh6dzvzMFQYzQ5V4IG1hkmig3z tq.duong@icloud.com",
        "dhp:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEpv1HpPeO5s10jM+drNiiFCDicchdJ4C9ecHb8wkXz dhng084@gmail.com",
        "dhp:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxVehBIHD4RpiKzCtPtiuB7mZ7EjlN225ItMImeJvTYvOh6X6/SBlL3tjSMnruLnUPK4XA9+XwKIYg8TmJvMM4tWVJurpjRzTMWNDgkbCWC3TeB1x38NtSf2nVopEvg+pZFfnkt7F/v9wirONOwWK/HfhpP9AcEOZ9m2Td+DAc3MqJF3OoiEbA1vL+lPyK0wqsqjO8tT/Hz+UAjYFLu0mEEoq4M78GJ+X6BWwG0Ps/6RFWi6wq2Gs6qbiOfg5hUD+5jF5qo3RQnQfS8MZKr7XrioEqFTbXoebBEilJiNtZ4/1CNmFnLIho8/0K3J1F9U6bZewDHgigetBs1aCtUfiRPijZ4ft1+Qz8Kqdl5/glx86kX/9sio4Wj1cVsxXKSvJXxESbjpe+J2m8EOUkf5gIeBg47p1A7/0QKN5qJQ6jFaELpBvvoLuxYDO+dOPYNV4Xe2fkIf/QzTpfFEe89nL0u/nieYDt1hBtHW6M7PgjjDaB6ETTcJkArv1EATfiJYPv0f5gfdpst+Gu9aPXhU3RkcYPy7sW1J87yKyg6jCC74ScPI06hL9H13xsAVhkVJTCgdHoepx3olCXY1J1w51cZzw/IhDiPSk3d1xbprR/8pe7rCHONYuke7diEFLAlrXCgMmPZkJDu11fhXEnnwaLdUXlAG6Btbj/FA8huDIAaw== ThanhTK4",
      ])
    },
    "ci-server" = {
      address      = "34.126.84.113"
      machine_type = local.machine_type.e2_medium
      region       = local.region_southeast1
      status       = local.terminated
      zone         = local.zone_southeast1
    },
    "jitsi-server" = {
      address      = "35.240.162.220"
      machine_type = local.machine_type.e2_standard_2
      snapshot     = "projects/${local.project_id}/global/snapshots/jitsi-server-${local.snapshot_date}"
      region       = local.region_southeast1
      status       = local.running
      tcp_ports    = ["5222", "5349"]
      udp_ports    = ["10000"]
      zone         = local.zone_southeast1
    },
  }
}

module "servers" {
  for_each = local.servers

  source = "../modules/fhs-instance-ubuntu"

  project_id = local.project_id

  address      = each.value.address
  machine_type = each.value.machine_type

  additional_tcp_ports = lookup(each.value, "tcp_ports", [])
  additional_udp_ports = lookup(each.value, "udp_ports", [])
  ssh_keys             = lookup(each.value, "ssh_keys", "")

  # resource_policy_id    = try(google_compute_resource_policy.all_day_08_to_23[each.value.region].id, null)
  server_name           = each.key
  server_status         = each.value.status
  service_account_email = google_service_account.this.email
  image                 = local.ubuntu_2204_image
  snapshot              = lookup(each.value, "snapshot", "")

  region = each.value.region
  zone   = each.value.zone

  depends_on = [google_project_iam_member.compute_system_account_permissions]
}
