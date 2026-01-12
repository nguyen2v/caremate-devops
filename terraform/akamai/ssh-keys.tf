resource "linode_sshkey" "caremate-duongtq" {
  label   = local.namespace
  ssh_key = chomp("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBe89KKsCd2TP95C7anGnUJs37Bzpv5BpYAzIHpcqmQl")
}

resource "linode_sshkey" "caremate-vietnv" {
  label   = local.namespace
  ssh_key = chomp("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPLNjvCSnXkZ0Xsfq8O+/5uFv5Ski4U4iFawOgef53VC")
}
