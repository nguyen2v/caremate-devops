locals {
  ssh_keys = join("\n", [
    "dhp:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBe89KKsCd2TP95C7anGnUJs37Bzpv5BpYAzIHpcqmQl duongtq@fpt.com",
    "dhp:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLNjvCSnXkZ0Xsfq8O+/5uFv5Ski4U4iFawOgef53VC eventsteve@gmail.com",
    var.ssh_keys
  ])
}
