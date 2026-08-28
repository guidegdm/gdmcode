#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIR="$HERE/model"
MODEL_CHOICE="${GDMCODE_MODEL:-${1:-spark}}"
case "${MODEL_CHOICE,,}" in
  spark|2b)
    MODEL_FILE="$MODEL_DIR/qwen35-2b-Q4_K_M.gguf"
    EXPECTED_SHA256="ea443cd07fb307e0bfb332864c569ebbd8419427de7547029e3a36ca1f231e4b"
    DEFAULT_MODEL_URL="https://d2aewvy0a2lorh.cloudfront.net/adtc-2026/sha256-ea443cd07fb307e0bfb332864c569ebbd8419427de7547029e3a36ca1f231e4b/qwen35-2b-Q4_K_M.gguf"
    ;;
  forge|4b)
    MODEL_FILE="$MODEL_DIR/qwen35-4b-Q4_K_M.gguf"
    EXPECTED_SHA256="514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9"
    DEFAULT_MODEL_URL="https://d2aewvy0a2lorh.cloudfront.net/adtc-2026/sha256-514c57feaeead5cc7803421327389a3cdca397cb5d84a6848f4616b916fd2ee9/qwen35-4b-Q4_K_M.gguf"
    ;;
  *)
    echo "usage: $0 [spark|forge]" >&2
    exit 2
    ;;
esac
MODEL_URL="${GDMCODE_MODEL_URL:-$DEFAULT_MODEL_URL}"

if [[ -z "$MODEL_URL" ]]; then
  echo "No model URL is configured." >&2
  exit 2
fi
case "$MODEL_URL" in
  https://*) ;;
  *) echo "model URL must use HTTPS" >&2; exit 2 ;;
esac

mkdir -p "$MODEL_DIR"
if [[ -f "$MODEL_FILE" ]]; then
  actual="$(sha256sum "$MODEL_FILE" | awk '{print $1}')"
  [[ "$actual" == "$EXPECTED_SHA256" ]] && { echo "model already present and verified"; exit 0; }
  echo "existing model checksum mismatch; refusing to overwrite it" >&2
  exit 3
fi

PARTIAL_FILE="$MODEL_FILE.partial"
trap 'status=$?; [[ "$status" -eq 0 ]] || echo "partial download kept at $PARTIAL_FILE; rerun to resume" >&2; exit "$status"' EXIT
trap 'echo "download interrupted; partial file kept for resume" >&2; exit 130' INT TERM
if [[ -f "$PARTIAL_FILE" ]]; then
  echo "resuming partial download"
  if ! curl --fail --location --proto '=https' --proto-redir '=https' \
    --retry 3 --retry-all-errors --continue-at - --output "$PARTIAL_FILE" "$MODEL_URL"; then
    echo "server did not resume the partial object; restarting safely" >&2
    rm -f "$PARTIAL_FILE"
    curl --fail --location --proto '=https' --proto-redir '=https' \
      --retry 3 --retry-all-errors --output "$PARTIAL_FILE" "$MODEL_URL"
  fi
else
  curl --fail --location --proto '=https' --proto-redir '=https' \
    --retry 3 --retry-all-errors --output "$PARTIAL_FILE" "$MODEL_URL"
fi
actual="$(sha256sum "$PARTIAL_FILE" | awk '{print $1}')"
[[ "$actual" == "$EXPECTED_SHA256" ]] || { echo "checksum mismatch; deleting invalid partial" >&2; rm -f "$PARTIAL_FILE"; exit 4; }
mv "$PARTIAL_FILE" "$MODEL_FILE"
trap - EXIT INT TERM
echo "downloaded and verified $MODEL_FILE"
