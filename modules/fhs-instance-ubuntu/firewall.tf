resource "google_compute_firewall" "rules_tcp" {
  name        = "${var.server_name}-firewall-rule-tcp"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = setunion(concat(["22", "80", "443", ]), var.additional_tcp_ports)
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.server_name}-firewall"]
}

resource "google_compute_firewall" "rules_udp" {
  name        = "${var.server_name}-firewall-rule-dhp"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "udp"
    ports    = setunion(concat([]), var.additional_udp_ports)
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.server_name}-firewall"]
}
