#!/usr/bin/env bash
set -euo pipefail
PREFIX="${PREFIX:-/usr/local/bin}"
URL="${URL:-https://github.com/Bleepit/scriptbeacon-clients/blob/a8b0aa82a560bd83a244fbdd3d7c914c18232ac3/bash/beam}"
tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT
echo "Downloading beam → $PREFIX/beam"
curl -fsSL "$URL" -o "$tmp"
chmod +x "$tmp"
sudo mkdir -p "$PREFIX"
sudo mv "$tmp" "$PREFIX/beam"
echo "beam installed at $PREFIX/beam"
echo "Try: beam verify   or   echo -e '#!/usr/bin/env beam\necho hi' > /tmp/x.sh && chmod +x /tmp/x.sh && /tmp/x.sh"
