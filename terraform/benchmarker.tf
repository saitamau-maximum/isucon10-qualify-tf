resource "sakuracloud_server" "isucon10q-benchmarker" {
  name = var.benchmarker_name
  zone = var.zone

  core   = 2
  memory = 4
  disks  = [sakuracloud_disk.isucon10q-benchmarker.id]

  network_interface {
    upstream = "shared"
  }

  network_interface {
    upstream = sakuracloud_switch.isucon10q-switch.id
  }


  user_data = join("\n", [
    "#cloud-config",
    local.benchmarker-cloud-config,
    yamlencode({
      ssh_pwauth : false,
      ssh_authorized_keys : [
        file(var.public_key_path),
      ],
    }),
  ])
}

resource "sakuracloud_disk" "isucon10q-benchmarker" {
  name = var.benchmarker_name
  zone = var.zone

  size              = 20
  source_archive_id = data.sakuracloud_archive.ubuntu.id
}

data "http" "benchmarker-cloud-config-source" {
  url = "https://raw.githubusercontent.com/saitamau-maximum/isucon-10-qualify-tf/main/cloud-init/bench.cfg"
}

locals {
  benchmarker-cloud-config = replace(data.http.benchmarker-cloud-config-source.body, "#cloud-config", "")
}

output "benchmarker_ip_address" {
  value = sakuracloud_server.isucon10q-benchmarker.ip_address
}
