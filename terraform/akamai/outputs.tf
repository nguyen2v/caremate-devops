output "server_ips" {
  value = {
    for name, instance in linode_instance.servers : name => instance.ip_address
  }
}

output "server_statuses" {
  value = {
    for name, instance in linode_instance.servers : name => instance.status
  }
}
