#!/bin/bash
# git-sync-login.sh
# Sync script met login via HTTPS token

set -e
set -euo pipefail

source .env-git

# Config — stel deze in voordat je het script draait
: "${GIT_REPO_URL:?GIT_REPO_URL is niet ingesteld}"
: "${GIT_USERNAME:?GIT_USERNAME is niet ingesteld}"
: "${GIT_TOKEN:?GIT_TOKEN is niet ingesteld}"

COMMIT_MSG="${1:-Auto commit $(date '+%Y-%m-%d %H:%M:%S')}"

# Check git repo
if [ ! -d .git ]; then
    echo "❌ Deze map is geen git repository"
    exit 1
fi

# Voeg alle wijzigingen toe
git add .

# Commit
git commit -m "$COMMIT_MSG" || echo "⚠️ Geen wijzigingen om te committen"

# Configureer remote met token (veilig: token niet in repo opgeslagen)
git remote set-url origin "https://${GIT_USERNAME}:${GIT_TOKEN}@${GIT_REPO_URL#https://}"

# Pull en rebase
git pull --rebase origin main

# Push
git push origin main

echo "✅ Git sync voltooid"
