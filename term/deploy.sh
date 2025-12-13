#!/usr/bin/env bash
set -euo pipefail

echo
echo "------------------------------------"
echo "clean + deply, starting now..."
echo "------------------------------------"

if [[ -d public ]]; then
  find public -mindepth 1 \
    -not -path "public/.*" \
    -not -name "." \
    -delete
fi

echo
echo "public/ after cleaning"
echo "----------------------------"
ls -a public || true

echo
echo "building site"
echo "----------------------------"
hugo --minify --gc --cleanDestinationDir

echo
echo "public/ after building"
echo "----------------------------"
ls -a public

echo
echo "deploying"
echo "----------------------------"
cd public

git add -A

if git diff --cached --quiet; then
  echo "no changes to commit"
else
  git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
  git push
  echo "deployed successfully"
fi

cd ..
echo
echo "done! restarting server…"
echo "------------------------------------"
hugo server -D
