resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "../id_ed25519"
  file_permission = "0600"
}

resource "yandex_vpc_network" "default" {
  name = "vm-network"
}

resource "yandex_vpc_subnet" "default" {
  name           = "vm-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_compute_instance" "this" {
  for_each = yamldecode(file("./nodes.yaml"))

  name        = each.key
  hostname    = each.key
  platform_id = "standard-v1"
  zone        = var.yc_zone

  resources {
    cores  = each.value.cpu
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.debian12.id
      size     = each.value.disk
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "debian:${tls_private_key.ssh_key.public_key_openssh}"
  }

  lifecycle {
    ignore_changes = [
      boot_disk
    ]
  }
}

resource "local_file" "inventory" {
  filename = "../inventory/prod/inventory.ini"

  content = <<EOF
[kube_control_plane]
%{~for name, instance in yandex_compute_instance.this}
%{~if startswith(name, "master")}
${name} ansible_host=${instance.network_interface[0].nat_ip_address} ip=${instance.network_interface[0].ip_address} etcd_member_name=etcd-${name}
%{~endif}
%{~endfor}

[etcd:children]
kube_control_plane

[kube_node]
%{~for name, instance in yandex_compute_instance.this}
%{~if startswith(name, "worker")}
${name} ansible_host=${instance.network_interface[0].nat_ip_address} ip=${instance.network_interface[0].ip_address}
%{~endif}
%{~endfor}

[all:vars]
ansible_user=debian
ansible_ssh_private_key_file=${abspath(local_file.private_key_pem.filename)}
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
EOF
}

output "nodes" {
  value = {
    for name, instance in yandex_compute_instance.this :
    name => instance.network_interface[0].nat_ip_address
  }
}
