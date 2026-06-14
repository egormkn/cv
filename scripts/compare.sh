#!/bin/bash

set -euxo pipefail

OLD_DIR="./old"
NEW_DIR="./new"
DIFF_DIR="./diff"

STATUS=0

# Check for files that only exist in one directory
FILES_DIFF=$(diff -qr "$OLD_DIR" "$NEW_DIR" || true)
echo "$FILES_DIFF"
if grep -iq 'only' <<< "$FILES_DIFF"; then
  STATUS=1
fi

# Compare PDFs that exist in both directories
while IFS= read -r NEW_FILE; do
  REL_PATH="${NEW_FILE#./new/}"
  OLD_FILE="$OLD_DIR/$REL_PATH"
  [ -e "$OLD_FILE" ] || continue

  DIFF_FILE="$DIFF_DIR/$REL_PATH"
  mkdir -p "$(dirname "$DIFF_FILE")"

  if diff-pdf -gmv --output-diff="$DIFF_FILE" "$OLD_FILE" "$NEW_FILE"; then
    echo "$REL_PATH: OK"
  else
    STATUS=1
    echo "$REL_PATH: FAIL"
  fi
done < <(find "$NEW_DIR" -type f -name "*.pdf")

exit $STATUS
