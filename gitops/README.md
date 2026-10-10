# gitops

Desired state that Argo CD reconciles (app-of-apps pattern).

- The **root** app-of-apps Application is bootstrapped by `terraform-platform` (it's part
  of the Argo CD install). It watches `cluster-addons/` on this repo's env branch
  (`main` → dev, `prod` → prod).
- `cluster-addons/` holds the **child Argo Applications** for the platform add-ons
  (Vault, kube-prometheus-stack, Loki, Vault Secrets Operator, the Gateway/edge, …).
  Each is added in its own phase.

The StoryCover application itself is **not** here — it lives in the `storycover-config`
repo (Kustomize) and has its own Argo Application.
