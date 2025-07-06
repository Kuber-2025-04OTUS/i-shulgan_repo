resource "helm_release" "consul" {
  name       = "argo-cd"
  namespace  = "argo-cd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = "8.0.13"

  atomic           = true
  create_namespace = true
  values           = [file("../argo-cd.values.yaml")]


  depends_on = [
    yandex_kubernetes_node_group.infra_pool
  ]
}

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  namespace  = "argo-cd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = "8.0.13"

  atomic           = true
  create_namespace = true
  values           = [file("../argo-cd.values.yaml")]


  depends_on = [
    yandex_kubernetes_node_group.infra_pool
  ]
}
