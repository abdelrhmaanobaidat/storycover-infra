# cluster-addons

Manifests reconciled by the app-of-apps root (recurses this directory). Ordering is set
with `argocd.argoproj.io/sync-wave`.

- `appprojects.yaml` (wave -10): two Argo `AppProject` fences. `platform` allows the infra
  repo plus Hashicorp Helm and cluster-scoped resources; `apps` allows the config repo only,
  confined to the `storycover` namespace with no cluster-scoped resources.
- `vault.yaml`, `vso.yaml`: Vault and the Vault Secrets Operator (project `platform`).
- `vault-secrets.yaml` (waves 1-2): the `storycover` namespace, `VaultConnection`,
  `VaultAuth`, and the `VaultStaticSecret` that VSO turns into the `gemini-api-key` Secret.
- `storycover.yaml` (wave 5, project `apps`): the app `Application`. It watches the config
  repo (`overlays/dev` on `main`) and reconciles it into the `storycover` namespace, after
  the namespace and secret above exist. Replica count is left to the HPA
  (`ignoreDifferences` on `/spec/replicas`).
- `gateway.yaml` (wave 6): the Gateway API edge. A `gke-l7-global-external-managed` Gateway
  (static IP and managed cert from `terraform/edge.tf`), an HTTP-to-HTTPS redirect, the HTTPS
  route to the app, and a `GCPBackendPolicy` attaching Cloud Armor and Cloud CDN.
- `monitoring.yaml` (wave 10): kube-prometheus-stack (Prometheus, Grafana, Alertmanager) on
  the management pool. Includes the app ServiceMonitor (scrapes `storycover` `/metrics`) and
  alert rules (target down, 5xx rate, p95 latency), plus a Grafana data source for Loki.
- `loki.yaml` (wave 10): Loki (single binary, ephemeral) and Promtail. Promtail tolerates the
  app taint so it collects logs from the application pool too.

All addons are deployed. Storage for Prometheus/Loki is ephemeral (dev); prod would use
persistent volumes or object storage.
