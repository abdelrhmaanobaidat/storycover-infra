# Two ordered releases: argo-cd (engine + CRDs, wait=true) then the app-of-apps root (depends_on, so the Application CR applies after its CRD exists).
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  wait    = true
  timeout = 900
}

resource "helm_release" "root_app" {
  name      = "root-app"
  namespace = "argocd"

  chart = "${path.module}/charts/app-of-apps"

  values = [yamlencode({
    repoURL  = var.gitops_repo_url
    revision = var.gitops_revision
  })]

  depends_on = [helm_release.argocd]
}
