#!/usr/bin/env bash
set -euo pipefail

RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[38;2;167;192;128m'   # Everforest green     #a7c080
CYAN='\033[38;2;127;187;179m'   # Everforest teal/cyan  #7fbbb3
YELLOW='\033[38;2;219;188;127m' # Everforest yellow     #dbbc7f
BLUE='\033[38;2;131;192;146m'   # Soft accent           #83c092
MAGENTA='\033[38;2;214;153;182m' # Subtle magenta        #d699b6

SEP_HEAVY="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SEP_LIGHT="──────────────────────────────────────────────────────────────────────────────"

echo
echo -e "${GREEN}${SEP_HEAVY}${RESET}"
echo -e "${BOLD}${GREEN}CLEAN + DEPLOY, STARTING NOW...${RESET}"
echo -e "${GREEN}${SEP_HEAVY}${RESET}"
echo

if [[ -d public ]]; then
  echo -e "${YELLOW}→ Cleaning public/ directory...${RESET}"
  find public -mindepth 1 \
    -not -path "public/.*" \
    -not -name "." \
    -delete
fi

echo
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
echo -e "${BOLD}${CYAN}PUBLIC/ AFTER CLEANING${RESET}"
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
ls -a public || true

echo
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
echo -e "${BOLD}${CYAN}BUILDING SITE${RESET}"
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
hugo --minify --gc --cleanDestinationDir

echo
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
echo -e "${BOLD}${CYAN}PUBLIC/ AFTER BUILDING${RESET}"
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
ls -a public

echo
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
echo -e "${BOLD}${CYAN}DEPLOYING${RESET}"
echo -e "${CYAN}${SEP_LIGHT}${RESET}"
cd public
git add -A
if git diff --cached --quiet; then
  echo -e "${YELLOW}NO CHANGES TO COMMIT${RESET}"
else
  git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
  git push
  echo -e "${GREEN}DEPLOYED SUCCESSFULLY${RESET}"
fi
cd ..

echo
echo -e "${GREEN}${SEP_HEAVY}${RESET}"
echo -e "${BOLD}${GREEN}DONE! RESTARTING SERVER…${RESET}"
echo -e "${GREEN}${SEP_HEAVY}${RESET}"

hugo server -D

# #!/usr/bin/env bash
# set -euo pipefail
#
# echo
# echo "===================================="
# echo "CLEAN + DEPLOY, STARTING NOW..."
# echo "----------------------------"
#
# if [[ -d public ]]; then
#   find public -mindepth 1 \
#     -not -path "public/.*" \
#     -not -name "." \
#     -delete
# fi
#
# echo
# echo "PUBLIC/ AFTER CLEANING"
# echo "----------------------------"
# ls -a public || true
#
# echo
# echo "BUILDING SITE"
# echo "----------------------------"
# hugo --minify --gc --cleanDestinationDir
#
# echo
# echo "PUBLIC/ AFTER BUILDING"
# echo "----------------------------"
# ls -a public
#
# echo
# echo "DEPLOYING"
# echo "----------------------------"
# cd public
#
# git add -A
#
# if git diff --cached --quiet; then
#   echo "NO CHANGES TO COMMIT"
# else
#   git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
#   git push
#   echo "DEPLOYED SUCCESSFULLY"
# fi
#
# cd ..
# echo
# echo "DONE! RESTARTING SERVER…"
# echo "===================================="
# hugo server -D
