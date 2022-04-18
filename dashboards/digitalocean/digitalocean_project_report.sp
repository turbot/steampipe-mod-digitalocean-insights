dashboard "digitalocean_project_report" {

  title         = "DigitalOcean Project Report"
  documentation = file("./dashboards/digitalocean/docs/digitalocean_project_report.md")

  tags = merge(local.digitalocean_common_tags, {
    type     = "Report"
    category = "Projects"
  })

  container {

    card {
      query   = query.digitalocean_project_count
      width = 2
    }

  }

  table {
    query = query.digitalocean_project_table
  }

}

query "digitalocean_project_count" {
  sql = <<-EOQ
    select
      count(*) as "Projects"
    from
      digitalocean_project;
  EOQ
}

query "digitalocean_project_table" {
  sql = <<-EOQ
    select
      id as "ID",
      name as "Name",
      is_default as "Is Default",
      created_at as "Create Time"
    from
      digitalocean_project;
  EOQ
}
