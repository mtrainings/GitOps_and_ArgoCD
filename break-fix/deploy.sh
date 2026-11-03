#!/usr/bin/env bash
# Deploys the LAB12 break-fix scenarios: two Gitea repositories, one project, eight broken Applications
set -euo pipefail
: "${ROOT:?}" "${WORK:?}"
. "$ROOT/env/versions.env"
G=http://gitea:3000; A="$GITEA_USER:$GITEA_PASSWORD"
hub() { kubectl --context kind-hub "$@"; }

push_repo() {   # src-dir  owner/name  private(true|false)
  local src=$1 full=$2 owner=${2%%/*} name=${2#*/} dir="$WORK/${2//\//-}"
  if [[ $owner == "$GITEA_USER" ]]; then
    curl -fs -u "$A" -X POST "$G/api/v1/user/repos" -H 'Content-Type: application/json' \
      -d "{\"name\":\"$name\",\"default_branch\":\"main\",\"private\":$3}" >/dev/null || true
  else
    curl -fs -u "$A" -X POST "$G/api/v1/orgs" -H 'Content-Type: application/json' \
      -d "{\"username\":\"$owner\",\"visibility\":\"public\"}" >/dev/null || true
    curl -fs -u "$A" -X POST "$G/api/v1/orgs/$owner/repos" -H 'Content-Type: application/json' \
      -d "{\"name\":\"$name\",\"default_branch\":\"main\",\"private\":$3}" >/dev/null || true
  fi
  rm -rf "$dir"; cp -r "$src" "$dir"
  ( cd "$dir" && git init -q -b main && git config user.name "ParcelPal Dev" && git config user.email dev@parcelpal.local \
    && git add -A && git commit -qm "Release week" \
    && git remote add origin "http://$A@gitea:3000/$full.git" && git push -q -f -u origin main )
}

push_repo "$ROOT/break-fix/repo"   "$GITEA_USER/breakfix" false
push_repo "$ROOT/break-fix/ledger" finance/ledger         true
hub apply -f "$ROOT/break-fix/apps/project.yaml" >/dev/null       # the project must exist before its apps
hub apply -f "$ROOT/break-fix/apps/" >/dev/null
echo "8 tickets are open - read labs/LAB12-break-fix/README.md"
echo "repository to fix: $WORK/student-breakfix   (Argo CD objects: kubectl -n argocd edit application bfN)"
echo "score: ./bin/lab check"
