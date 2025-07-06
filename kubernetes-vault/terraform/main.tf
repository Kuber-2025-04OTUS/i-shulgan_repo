resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.project_name}-nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "${var.project_name}-route-table"
  network_id = yandex_vpc_network.k8s_network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_network" "k8s_network" {
  name = "${var.project_name}-network"
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = "${var.project_name}-subnet"
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
  zone           = var.yc_zone
  route_table_id = yandex_vpc_route_table.nat_route_table.id
}

resource "yandex_iam_service_account" "k8s_sa" {
  name        = "k8s-sa"
  description = "Service account for Kubernetes cluster"
}

resource "yandex_iam_service_account" "k8s_node_sa" {
  name        = "k8s-node-sa"
  description = "Service account for Kubernetes nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_roles" {
  for_each = toset([
    "editor",
    "container-registry.images.pusher",
    "container-registry.images.puller",
    "vpc.publicAdmin",
    "compute.viewer",
    "iam.serviceAccounts.user"
  ])
  folder_id = var.yc_folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_node_sa_roles" {
  for_each = toset([
    "container-registry.images.puller",
    "vpc.publicAdmin",
    "compute.viewer"
  ])
  folder_id = var.yc_folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s_node_sa.id}"
}

resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name        = "${var.project_name}-k8s"
  description = "Managed Kubernetes cluster"
  network_id  = yandex_vpc_network.k8s_network.id

  master {
    version = "1.32"
    zonal {
      zone      = var.yc_zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }
    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_node_sa.id

  release_channel = "REGULAR"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_sa_roles,
    yandex_resourcemanager_folder_iam_member.k8s_node_sa_roles
  ]
}


resource "yandex_kubernetes_node_group" "worker_pool" {
  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id
  name       = "worker-pool"
  version    = yandex_kubernetes_cluster.k8s_cluster.master[0].version

  instance_template {
    platform_id = "standard-v3"

    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s_subnet.id]
    }

    resources {
      cores         = 4
      memory        = 16
      core_fraction = 100
    }

    boot_disk {
      type = "network-ssd-nonreplicated"
      size = 93
    }

  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

}

resource "null_resource" "generate_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
      yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.k8s_cluster.id} --external --kubeconfig=./kubeconfig.yaml --force
    EOT
  }

  depends_on = [yandex_kubernetes_cluster.k8s_cluster]
}
