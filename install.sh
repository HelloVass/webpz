#!/usr/bin/env bash
set -euo pipefail

VERSION="${WEBPZ_VERSION:-latest}"
INSTALL_DIR="${WEBPZ_INSTALL_DIR:-$HOME/.local/bin}"
DATA_DIR="${WEBPZ_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/webpz}"
RELEASES="https://github.com/HelloVass/webpz/releases"

case "$(uname -s)" in
  Darwin) OS=darwin ;;
  Linux) OS=linux ;;
  *) echo "webpz supports macOS and Linux" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  arm64|aarch64) ARCH=arm64 ;;
  x86_64|amd64) ARCH=x64 ;;
  *) echo "webpz supports arm64 and x64" >&2; exit 1 ;;
esac

for tool in curl tar install; do
  command -v "$tool" >/dev/null 2>&1 || { echo "missing dependency: $tool" >&2; exit 1; }
done
if command -v sha256sum >/dev/null 2>&1; then
  CHECKSUM=(sha256sum)
elif command -v shasum >/dev/null 2>&1; then
  CHECKSUM=(shasum -a 256)
else
  echo "missing dependency: sha256sum or shasum" >&2
  exit 1
fi

if [[ "$VERSION" == latest ]]; then
  BASE_URL="$RELEASES/latest/download"
else
  VERSION="${VERSION#v}"
  [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid version: $VERSION" >&2; exit 1; }
  BASE_URL="$RELEASES/download/v$VERSION"
fi

ARCHIVE="webpz-$OS-$ARCH.tar.gz"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/webpz-install.XXXXXX")"
STAGED_BIN=""
cleanup() {
  rm -rf "$WORK_DIR"
  if [[ -n "$STAGED_BIN" ]]; then rm -f "$STAGED_BIN"; fi
}
trap cleanup EXIT

curl -fLsS --retry 3 "$BASE_URL/$ARCHIVE" -o "$WORK_DIR/$ARCHIVE"
curl -fLsS --retry 3 "$BASE_URL/$ARCHIVE.sha256" -o "$WORK_DIR/$ARCHIVE.sha256"
read -r EXPECTED CHECKED_FILE < "$WORK_DIR/$ARCHIVE.sha256"
[[ "$EXPECTED" =~ ^[a-fA-F0-9]{64}$ && "$CHECKED_FILE" == "$ARCHIVE" ]] || {
  echo "invalid checksum file" >&2; exit 1;
}
ACTUAL="$("${CHECKSUM[@]}" "$WORK_DIR/$ARCHIVE")"
[[ "${ACTUAL%% *}" == "$EXPECTED" ]] || { echo "SHA-256 mismatch; installation aborted" >&2; exit 1; }

tar -xzf "$WORK_DIR/$ARCHIVE" -C "$WORK_DIR" webpz
if tar -tzf "$WORK_DIR/$ARCHIVE" | grep -q '^licenses/'; then
  tar -xzf "$WORK_DIR/$ARCHIVE" -C "$WORK_DIR" README.md licenses
  mkdir -p "$DATA_DIR/licenses"
  cp "$WORK_DIR/licenses/"* "$DATA_DIR/licenses/"
  cp "$WORK_DIR/README.md" "$DATA_DIR/README.md"
fi
[[ -f "$WORK_DIR/webpz" && ! -L "$WORK_DIR/webpz" ]] || { echo "release binary missing" >&2; exit 1; }
chmod +x "$WORK_DIR/webpz"
"$WORK_DIR/webpz" --version

mkdir -p "$INSTALL_DIR"
STAGED_BIN="$(mktemp "$INSTALL_DIR/.webpz.XXXXXX")"
install -m 0755 "$WORK_DIR/webpz" "$STAGED_BIN"
mv -f "$STAGED_BIN" "$INSTALL_DIR/webpz"
STAGED_BIN=""
echo "installed $INSTALL_DIR/webpz"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) printf 'Add %s to PATH in your shell configuration.\n' "$INSTALL_DIR" ;;
esac
echo "Next: webpz doctor && webpz init"
