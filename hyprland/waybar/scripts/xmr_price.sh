#!/usr/bin/env bash
set -euo pipefail

curl_args=(
  "-fsS"
  "-4"
  "--max-time" "5"
  "--retry" "2"
  "--retry-delay" "1"
  "--retry-connrefused"
  "-H" "User-Agent: waybar-xmr/1.0"
)

emit_error() {
  local msg="$1"
  msg=${msg//\\/\\\\}
  msg=${msg//\"/\\\"}
  msg=${msg//$'\n'/ }
  printf '{"text":"XMR N/A","tooltip":"%s","class":"error"}\n' "$msg"
}

try_parse() {
  local source="$1"
  local json_payload="$2"
  python3 - "$source" "$json_payload" <<'PY'
import json
import sys

source = sys.argv[1]
payload = sys.argv[2]

try:
    data = json.loads(payload)
    if source == "kraken":
        if data.get("error"):
            raise ValueError(f"API error: {data['error']}")
        result = data["result"]
        if not result:
            raise ValueError("Empty result")
        pair_data = next(iter(result.values()))
        price = float(pair_data["c"][0])
        tooltip = "Monero (XMR) price in USD (Kraken)"
    elif source == "coingecko":
        price = float(data["monero"]["usd"])
        tooltip = "Monero (XMR) price in USD (CoinGecko)"
    else:
        raise ValueError("Unknown source")
    text = f"XMR ${price:,.2f}"
    print(json.dumps({"text": text, "tooltip": tooltip, "class": "ok"}))
except Exception as exc:
    print(str(exc), file=sys.stderr)
    sys.exit(1)
PY
}

kraken_url="https://api.kraken.com/0/public/Ticker?pair=XMRUSD"
coingecko_url="https://api.coingecko.com/api/v3/simple/price?ids=monero&vs_currencies=usd"

last_error="Price fetch failed"

for source in kraken coingecko; do
  if [[ "$source" == "kraken" ]]; then
    url="$kraken_url"
  else
    url="$coingecko_url"
  fi

  if response=$(curl "${curl_args[@]}" "$url" 2>&1); then
    if output=$(try_parse "$source" "$response" 2>&1); then
      printf '%s\n' "$output"
      exit 0
    else
      last_error="$source parse failed"
    fi
  else
    last_error="$source fetch failed: ${response:-unknown error}"
  fi
done

emit_error "$last_error"
