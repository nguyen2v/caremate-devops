output "boot_disk_id" {
  value = google_compute_instance.this.boot_disk[0].source
}

output "ip" {
  value = google_compute_address.this.address
}

output "status" {
  value = google_compute_instance.this.desired_status
}
