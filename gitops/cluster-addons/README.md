# cluster-addons

Child Argo CD `Application` manifests, synced by the app-of-apps root:

- Vault + Vault Secrets Operator
- Gateway API + Cloud Armor edge
- kube-prometheus-stack + Loki

Until the first one lands, this directory is intentionally empty (Argo reports the root
app as Synced with no resources).
