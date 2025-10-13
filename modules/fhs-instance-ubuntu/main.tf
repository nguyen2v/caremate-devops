resource "google_compute_address" "this" {
  address = var.address
  name    = "${var.server_name}-ip"
  region  = var.region
}

resource "google_compute_disk" "this" {
  name     = "${var.server_name}-disk"
  size     = var.disk_size
  image    = var.image
  snapshot = var.snapshot
  zone     = var.zone
}

resource "google_compute_instance" "this" {
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = true
    device_name = var.server_name
    mode        = "READ_WRITE"
    source      = google_compute_disk.this.self_link
  }

  can_ip_forward      = true
  deletion_protection = false
  desired_status      = var.server_status
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = var.machine_type
  name         = var.server_name

  network_interface {
    access_config {
      nat_ip = google_compute_address.this.address
    }
    network = "default"
  }

  metadata = {
    "ssh-keys" = local.ssh_keys
  }

  resource_policies = var.resource_policy_id != null ? [var.resource_policy_id] : []

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform", "compute-rw"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = [var.server_name, "${var.server_name}-firewall"]
  zone = var.zone
}
