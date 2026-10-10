# Argo CD is the only thing Terraform installs in-cluster. Its app-of-apps root
# (extraObjects below) then makes Argo CD manage everything else from Git, so Terraform's
# in-cluster footprint stays at this single bootstrap.
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version != "" ? var.argocd_chart_version : null

  # Wait for the components to be ready so the app-of-apps can reconcile.
  wait    = true
  timeout = 900

  values = [yamlencode({
    # app-of-apps root: Argo CD watches gitops/cluster-addons in this repo and manages the
    # child Applications (Vault, monitoring, ...) from there.
    extraObjects = [
      {
        apiVersion = "argoproj.io/v1alpha1"
        kind       = "Application"
        metadata = {
          name      = "cluster-addons"
          namespace = "argocd"
        }
        spec = {
          project = "default"
          source = {
            repoURL        = var.gitops_repo_url
            targetRevision = var.gitops_revision
            path           = "gitops/cluster-addons"
            directory      = { recurse = true }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "argocd"
          }
          syncPolicy = {
            automated   = { prune = true, selfHeal = true }
            syncOptions = ["CreateNamespace=true"]
          }
        }
      }
    ]
  })]
}
