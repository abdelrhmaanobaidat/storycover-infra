# cluster-addons

Child Argo CD `Application` manifests, synced by the app-of-apps root. Added per phase:

- Phase 6 — Vault + Vault Secrets Operator
- Phase 8 — Gateway API + Cloud Armor edge
- Phase 9 — kube-prometheus-stack + Loki

Until the first one lands, this directory is intentionally empty (Argo reports the root
app as Synced with no resources).
