locals {
  billing_account = "018013-8B530F-296E33"
  budget          = 2500000

  running    = "RUNNING"
  terminated = "TERMINATED"

  ubuntu_2204_image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250415"

  machine_type = {
    e2_medium     = "e2-medium"     # 2 vCPU, 1 Core,  4 GB memory
    e2_standard_2 = "e2-standard-2" # 2 vCPU, 1 Core,  8 GB memory
    e2_standard_4 = "e2-standard-4" # 4 vCPU, 2 Core, 16 GB memory
    e2_highmem_2  = "e2-highmem-2"  # 2 vCPU, 1 Core, 16 GB memory
    e2_highmem_4  = "e2-highmem-4"  # 4 vCPU, 2 Core, 32 GB memory
  }

  project_id        = "beaming-key-466311-v1"
  backup_project_id = "beaming-key-466311-v1"

  region_southeast1 = "asia-southeast1"
  zone_southeast1   = "asia-southeast1-c"
  region_southeast2 = "asia-southeast2"
  zone_southeast2   = "asia-southeast2-c"

  us_region = "us-central1"
  us_zone   = "us-central1-c"

  snapshot_date = "2025-02-17"

  primary_email   = "louis.llg.hc@gmail.com"
  secondary_email = "eventsteve@gmail.com"
}
