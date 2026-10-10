# vault

One-time Vault bootstrap (run by a human after Vault is up). Vault *server* config is
scripted here for reproducibility; the *secret values* are never committed.

## Steps (per environment)
1. **Initialize** (one-time; produces the recovery key + root token — store them safely,
   never in Git):

       kubectl -n vault exec -i vault-0 -- vault operator init \
         -recovery-shares=1 -recovery-threshold=1 -format=json > vault-init.json

   Vault auto-unseals via Cloud KMS (gcpckms).

2. **Configure** auth + policy + role (idempotent):

       export VAULT_TOKEN=$(jq -r .root_token vault-init.json)
       ./configure.sh

   This enables the kv-v2 engine, enables Kubernetes auth, writes the `storycover` policy
   (`read` on `secret/data/storycover/*`), and the `storycover` role (bound to the
   `storycover` namespace SAs).

3. **Seed the secret** with the real key (out-of-band, value not in Git):

       kubectl -n vault exec -i vault-0 -- sh -c \
         "VAULT_TOKEN=$VAULT_TOKEN vault kv put secret/storycover/gemini api_key=YOUR_REAL_KEY"

The GitOps side (VSO + `VaultConnection`/`VaultAuth`/`VaultStaticSecret`) lives in
`gitops/cluster-addons/`. Production evolution: manage this server config declaratively
with the **vault-config-operator** so it's drift-reconciled from Git rather than scripted.
