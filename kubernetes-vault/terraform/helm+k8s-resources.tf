resource "helm_release" "consul" {
  name       = "consul"
  namespace  = "consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "1.7.2"

  atomic           = true
  create_namespace = true
  values           = [file("../consul.values.yaml")]


  depends_on = [
    yandex_kubernetes_node_group.worker_pool
  ]
}

resource "helm_release" "vault" {
  name       = "vault"
  namespace  = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.30.0"

  atomic           = true
  create_namespace = true
  values           = [file("../vault.values.yaml")]


  depends_on = [
    helm_release.consul
  ]
}

resource "kubernetes_service_account_v1" "vault_auth" {

  metadata {
    name      = "vault-auth"
    namespace = "vault"
  }

  depends_on = [
    helm_release.vault
  ]

}


resource "kubernetes_cluster_role_binding" "vault_auth_delegator" {

  metadata {
    name = "vault-auth-delegator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.vault_auth.metadata[0].name
    namespace = kubernetes_service_account_v1.vault_auth.metadata[0].namespace
  }
}

resource "kubernetes_manifest" "vault_k8s_auth_secret" {
  manifest = yamldecode(file("../vault-k8s-auth-secret.yaml"))

  depends_on = [
    kubernetes_cluster_role_binding.vault_auth_delegator
  ]
}


resource "helm_release" "external-secrets" {
  name       = "external-secrets"
  namespace  = "vault"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.18.2"

  atomic           = true
  create_namespace = true

  depends_on = [
    kubernetes_cluster_role_binding.vault_auth_delegator
  ]
}

resource "kubernetes_manifest" "secret_store" {
  manifest = yamldecode(file("../SecretStore.yaml"))

  depends_on = [
    helm_release.external-secrets
  ]
}

resource "kubernetes_manifest" "external_secret" {
  manifest = yamldecode(file("../ExternalSecret.yaml"))

  depends_on = [
    helm_release.external-secrets
  ]
}