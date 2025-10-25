#!/usr/bin/env bash
set -euo pipefail

# Destination (uses sudo if available; otherwise falls back to ~/.local/bin)
DEST_DEFAULT="/usr/local/bin"
if command -v sudo >/dev/null 2>&1; then
  DEST="${PREFIX:-$DEST_DEFAULT}"
  USE_SUDO="sudo"
else
  DEST="${PREFIX:-$HOME/.local/bin}"
  USE_SUDO=""
fi

# Source URL (raw GitHub). You can pin to a tag by exporting BEAM_VERSION=v0.3.0
REPO="Bleepit/scriptbeacon-clients"
REF="${BEAM_VERSION:-main}"
URL="${URL:-https://raw.githubusercontent.com/${REPO}/${REF}/bash/beam}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Downloading beam → ${DEST}/beam"
curl -fsSL "$URL" -o "$tmp"

# Quick sanity check: make sure we didn't download HTML
if head -n 1 "$tmp" | grep -qi '<!DOCTYPE html>'; then
  echo "ERROR: Downloaded HTML instead of the beam script."
  echo "Check the URL (must be a raw.githubusercontent.com link):"
  echo "  $URL"
  exit 1
fi

chmod +x "$tmp"
$USE_SUDO mkdir -p "$DEST"
$USE_SUDO mv "$tmp" "${DEST}/beam"

echo "beam installed at ${DEST}/beam"

# PATH hint if needed
if ! command -v beam >/dev/null 2>&1; then
  echo
  echo "Note: 'beam' is not on your PATH."
  echo "Add this to your shell profile if needed:"
  echo "  export PATH=\"${DEST}:\$PATH\""
fi

echo "Try: beam verify   or   echo -e '#!/usr/bin/env beam\necho hi' > /tmp/x.sh && chmod +x /tmp/x.sh && /tmp/x.sh"
