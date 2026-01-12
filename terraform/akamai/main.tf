resource "linode_instance" "terraform-web" {
  image           = "linode/ubuntu24.04"
  label           = "Terraform-Web-Example"
  region          = "us-east"
  type            = "g6-standard-1"
  authorized_keys = ["YOUR_PUBLIC_SSH_KEY"]
  root_pass       = "YOUR_ROOT_PASSWORD"

  tags = ["caremate"]
}
