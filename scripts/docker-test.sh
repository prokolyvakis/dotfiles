#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE_NAME="dotfiles-test"

echo "=== Building Docker smoke test ==="
echo "This builds a clean Ubuntu 24.04 container and runs the full setup."
echo ""

cd "$REPO_DIR"

docker build \
  --no-cache \
  --progress=plain \
  -t "$IMAGE_NAME" \
  -f Dockerfile \
  .

echo ""
echo "=== Smoke test passed ==="
echo ""
echo "To inspect the result interactively:"
echo "  docker run --rm -it $IMAGE_NAME"
