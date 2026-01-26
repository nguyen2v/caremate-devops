variable "additional_tcp_ports" {
  type        = list(string)
  description = "More TCP port"
  default     = []
}

variable "additional_udp_ports" {
  type        = list(string)
  description = "More UDP port"
  default     = []
}

variable "project_id" {
  type        = string
  description = "Project Id"
}

variable "image" {
  type        = string
  description = "Linux image to use"
  default     = ""
}

variable "snapshot" {
  type        = string
  description = "Link to snapshot"
  default     = ""
}

variable "address" {
  type        = string
  description = "IPv4 address"
  default     = null
}

variable "disk_params" {
  description = "Boot disk init params"
  type = list(object({
    image = string
  }))
  default = [{
    image = "projects/debian-cloud/global/images/debian-11-bullseye-v20230814"
  }]
}

variable "disk_size" {
  type        = number
  description = "Disk size"
  default     = 50
}

variable "machine_type" {
  type        = string
  description = "Machine type"
}

variable "server_name" {
  type        = string
  description = "Server name"
}

variable "server_status" {
  type        = string
  description = "Server status. Either RUNNING or TERMINATED"
}

variable "service_account_email" {
  type        = string
  description = "Service account email"
}

variable "ssh_keys" {
  type        = string
  description = "Additional ssh-keys"
  default     = ""
}

variable "region" {
  type        = string
  description = "Region"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "resource_policy_id" {
  type        = string
  description = "Resource policy id"
  default     = null
}
