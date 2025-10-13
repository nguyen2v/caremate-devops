output "server_ips" {
  value = {
    for name, mod in module.servers : name => mod.ip
  }
}

output "server_statuses" {
  value = {
    for name, mod in module.servers : name => mod.status
  }
}
