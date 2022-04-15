dashboard "digitalocean_account_report" {

  title         = "DigitalOcean Account Report"
  documentation = file("./dashboards/digitalocean/docs/digitalocean_account_report.md")

  tags = merge(local.digitalocean_common_tags, {
    type     = "Report"
    category = "Accounts"
  })

  container {

    card {
      query   = query.digitalocean_account_count
      width = 2
    }

  }

  table {
    query = query.digitalocean_account_table
  }

}

query "digitalocean_account_count" {
  sql = <<-EOQ
    select
      count(*) as "Accounts"
    from
      digitalocean_account;
  EOQ
}

query "digitalocean_account_table" {
  sql = <<-EOQ
    select
      uuid as "Account ID",
      email as "Email ID",
      status as "Status",
      droplet_limit as "Droplet Limit",
      floating_ip_limit as "Floating IP Limit",
      volume_limit as "Volume Limit"
    from
      digitalocean_account;
  EOQ
}
