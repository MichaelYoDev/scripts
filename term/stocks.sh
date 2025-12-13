#!/usr/bin/env bash

tickers=(PBR AMZN NVDA SMCI FIG ACHR RIVN)

curl -s "https://terminal-stocks.dev/PBR,AMZN,NVDA,SMCI,FIG,ACHR,RIVN" |
  sed -n "/│ /p" |
  awk -F"│" 'NF>=5 {printf "%s %s %s %s\n", $3, $4, $5, $6}' |
  sed "s/^ *//" |
  awk -v t="${tickers[*]}" '
    BEGIN {
      split(t,a)
      printf "%-6s %-10s %-8s %-8s\n", "TICKER", "PRICE", "CHANGE", "%CHG"
      print  "--------------------------------------"
    }
    {printf "%-6s %-10s %-8s %-8s\n", a[NR], $1, $2, $3}
  '

echo
read -n 1 -s -r -p "Press any key to close..."
