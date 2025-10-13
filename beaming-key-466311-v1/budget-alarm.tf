resource "google_monitoring_notification_channel" "notification_channel_primary" {
  display_name = "Notification Channel 1"
  type         = "email"

  labels = {
    email_address = local.primary_email
  }
}

resource "google_monitoring_notification_channel" "notification_channel_secondary" {
  display_name = "Notification Channel 2"
  type         = "email"

  labels = {
    email_address = local.secondary_email
  }
}

resource "google_billing_budget" "budget" {
  billing_account = local.billing_account
  display_name    = "GCP Budget Alert"

  amount {
    specified_amount {
      currency_code = "VND"
      units         = local.budget
    }
  }

  threshold_rules {
    threshold_percent = 0.8
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.notification_channel_primary.id,
      google_monitoring_notification_channel.notification_channel_secondary.id,
    ]
    disable_default_iam_recipients = true
  }
}
