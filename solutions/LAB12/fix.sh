#!/usr/bin/env bash
# Reference fixes for the LAB12 break-fix challenge (instructor / smoke test).  Run from the course repo root.
set -euo pipefail
. env/versions.env
hub() { kubectl --context kind-hub "$@"; }
patch() { hub -n argocd patch application "$1" --type merge -p "$2" >/dev/null; }
R=work/student-breakfix

# BF1 - path typo
patch bf1 '{"spec":{"source":{"path":"bf1/manifests"}}}'
# BF2 - branch typo
patch bf2 '{"spec":{"source":{"targetRevision":"main"}}}'
# BF3 - destination not permitted by the project
patch bf3 '{"spec":{"destination":{"namespace":"bf-3"}}}'
# BF4 - namespace does not exist
patch bf4 '{"spec":{"syncPolicy":{"syncOptions":["CreateNamespace=true"]}}}'
# BF5 - failing PreSync hook (empty DB_HOST)
sed -i 's/              value: ""/              value: "invoices-db.bf-5.svc"/' $R/bf5/db-check.yaml
# BF6 - sync wave deadlock: the ConfigMap must come first
sed -i 's/argocd.argoproj.io\/sync-wave: "1"/argocd.argoproj.io\/sync-wave: "-1"/' $R/bf6/configmap.yaml
# BF8 - image tag typo
sed -i 's/newTag: 6.15.O/newTag: 6.15.0/' $R/bf8/kustomization.yaml
( cd $R && git commit -qam "Fix BF5, BF6, BF8" && git push -q )
# BF6 - the running sync waits forever for wave 0: stop it, the next one picks up the fix
argocd app terminate-op bf6 >/dev/null 2>&1 || true
# BF7 - credentials for a repository outside http://gitea:3000/student/
hub apply -f - >/dev/null <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: finance-ledger
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea:3000/finance/ledger.git
  username: $GITEA_USER
  password: $GITEA_PASSWORD
YAML
for n in 1 2 3 4 5 6 7 8; do argocd app get bf$n --refresh >/dev/null 2>&1 || true; done
