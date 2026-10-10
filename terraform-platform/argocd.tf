# Argo CD is the only thing Terraform installs in-cluster. Two releases, ordered:
#   1) argo-cd      — the engine + its CRDs (wait=true, so CRDs are Established)
#   2) app-of-apps  — the root Application (separate release, depends_on #1), so the
#      Application CR is only applied AFTER its CRD exists (avoids the CRD race).
# After this, Argo CD manages everything else from Git (gitops/cluster-addons).
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
