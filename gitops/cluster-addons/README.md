# cluster-addons

Manifests reconciled by the app-of-apps root (recurses this directory). Ordering is set
with `argocd.argoproj.io/sync-wave`.

- `appprojects.yaml` (wave -10) — two Argo `AppProject` fences: `platform` (infra repo +
  Hashicorp Helm, cluster-scoped allowed) and `apps` (config repo only, confined to the
  `storycover` namespace, no cluster-scoped resources).
- `vault.yaml`, `vso.yaml` — Vault and the Vault Secrets Operator (project `platform`).
- `vault-secrets.yaml` (waves 1-2) — the `storycover` namespace, `VaultConnection`,
  `VaultAuth`, and the `VaultStaticSecret` that VSO turns into the `gemini-api-key` Secret.
- `storycover.yaml` (wave 5, project `apps`) — the app `Application`; watches the config
  repo (`overlays/dev` on `main`) and reconciles it into the `storycover` namespace, after
  the namespace and secret above exist. Replica count is left to the HPA
  (`ignoreDifferences` on `/spec/replicas`).

Still to land here: Gateway API + Cloud Armor edge, and kube-prometheus-stack + Loki.
