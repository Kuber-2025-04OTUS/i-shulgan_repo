resource "helm_release" "loki" {
  name       = "loki"
  namespace  = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.30.1"

  atomic           = true
  create_namespace = true
  values           = [file("../loki.values.yaml")]

  set {
    name  = "loki.storage_config.aws.bucketnames"
    value = yandex_storage_bucket.loki_logs.bucket
  }

  set {
    name  = "loki.storage.bucketNames.chunks"
    value = yandex_storage_bucket.loki_logs.bucket
  }

  set {
    name  = "loki.storage.bucketNames.ruler"
    value = yandex_storage_bucket.loki_logs.bucket
  }

  set {
    name  = "loki.storage.bucketNames.admin"
    value = yandex_storage_bucket.loki_logs.bucket
  }

  set {
    name  = "loki.storage.s3.accessKeyId"
    value = yandex_iam_service_account_static_access_key.s3_access_sa.access_key
  }

  set {
    name  = "loki.storage.s3.secretAccessKey"
    value = yandex_iam_service_account_static_access_key.s3_access_sa.secret_key
  }

  depends_on = [
    yandex_kubernetes_node_group.infra_pool
  ]
}


resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.16.0"

  atomic           = true
  create_namespace = true
  values           = [file("../promtail.values.yaml")]

  depends_on = [
    helm_release.loki
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "9.2.6"

  atomic           = true
  create_namespace = true
  values           = [file("../grafana.values.yaml")]

  depends_on = [
    helm_release.loki
  ]
}