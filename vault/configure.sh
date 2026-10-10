#!/usr/bin/env bash
# One-time Vault config after 'vault operator init': kv-v2 engine, Kubernetes auth, policy, role.
set -euo pipefail

NS="${VAULT_NAMESPACE:-vault}"
POD="${VAULT_POD:-vault-0}"
TOKEN="${VAULT_TOKEN:?export VAULT_TOKEN=<root token from 'vault operator init'>}"

kubectl -n "$NS" exec -i "$POD" -- sh -c "
export VAULT_TOKEN='$TOKEN'
vault secrets enable -path=secret kv-v2 2>/dev/null || true
vault auth enable kubernetes 2>/dev/null || true
vault write auth/kubernetes/config kubernetes_host='https://kubernetes.default.svc'
printf 'path \"secret/data/storycover/*\" { capabilities = [\"read\"] }\n' | vault policy write storycover -
vault write auth/kubernetes/role/storycover bound_service_account_names='default,storycover-app' bound_service_account_namespaces='storycover' policies='storycover' ttl='1h'
"

echo "Done. Seed the secret separately with the real key (value is never committed):"
echo "  kubectl -n $NS exec -i $POD -- sh -c \"VAULT_TOKEN=\$TOKEN vault kv put secret/storycover/gemini api_key=YOUR_REAL_KEY\""
