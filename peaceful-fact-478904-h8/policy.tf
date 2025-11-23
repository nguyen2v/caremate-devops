locals {
  regions = [local.region_southeast1]
}

resource "google_compute_resource_policy" "working_day_08_to_18" {
  for_each    = toset(local.regions)
  name        = "gce-servers-policy-working-day-08-to-18-${each.key}"
  description = "Start and stop instances (08:00 - 18:00, Mon-Fri) in ${each.key}"
  region      = each.key

  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 6 * * 1-5"
    }

    vm_stop_schedule {
      schedule = "0 18 * * 1-5"
    }

    time_zone = "Asia/Ho_Chi_Minh"
  }
}

resource "google_compute_resource_policy" "all_day_08_to_23" {
  for_each    = toset(local.regions)
  name        = "gce-servers-policy-all-day-08-to-23-${each.key}"
  description = "Start and stop instances (08:00 - 23:00 daily) in ${each.key}"
  region      = each.key

  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 6 * * *"
    }

    vm_stop_schedule {
      schedule = "0 23 * * *"
    }

    time_zone = "Asia/Ho_Chi_Minh"
  }
}
