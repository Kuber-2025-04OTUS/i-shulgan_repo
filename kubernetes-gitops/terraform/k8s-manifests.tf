resource "kubernetes_manifest" "argocd_project" {
  manifest = yamldecode(file("../AppProject.yaml"))

  depends_on = [
    helm_release.argo-cd
  ]
}

resource "kubernetes_manifest" "argocd_app_k8s_networks" {
  manifest = yamldecode(file("../ApplicationKubernetesNetworks.yaml"))

  depends_on = [
    kubernetes_manifest.argocd_project
  ]
}

resource "kubernetes_manifest" "argocd_app_k8s_templating" {
  manifest = yamldecode(file("../ApplicationKubernetesTemplating.yaml"))

  depends_on = [
    kubernetes_manifest.argocd_project
  ]
}
