resource "helm_release" "ya_csi_s3" {
  name       = "csi-s3"
  namespace  = "yandex-csi-s3"
  repository = "https://yandex-cloud.github.io/k8s-csi-s3/charts"
  chart      = "csi-s3"
  version    = "0.43.0"

  atomic           = true
  create_namespace = true

  set = [{
    name  = "storageClass.singleBucket"
    value = yandex_storage_bucket.csi.bucket
    },
    {
      name  = "secret.accessKey"
      value = yandex_iam_service_account_static_access_key.s3_access_sa.access_key
    },
    {
      name  = "secret.secretKey"
      value = yandex_iam_service_account_static_access_key.s3_access_sa.secret_key
    }
  ]
  depends_on = [
    yandex_kubernetes_node_group.worker_pool
  ]
}

resource "kubernetes_manifest" "pvc" {
  manifest = yamldecode(file("../pvc.yaml"))

  depends_on = [
    helm_release.ya_csi_s3
  ]
}

resource "kubernetes_manifest" "deployment" {
  manifest = yamldecode(file("../deployment.yaml"))

  depends_on = [
    kubernetes_manifest.pvc
  ]
}
