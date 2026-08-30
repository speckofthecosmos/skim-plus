#!/bin/bash
# Apply patches/ to ./upstream and build Skim.app (ad-hoc signed).
# Usage: build.sh
# Output: build/Release/Skim.app inside ./upstream, zipped to ./Skim-plus.zip
#
# Build notes (learned the hard way):
# - SYMROOT must be ABSOLUTE: a relative value resolves per-subproject and
#   SkimImporter then can't find the sibling-built SkimNotesBase.framework.
# - On machines where only Command Line Tools are selected, point
#   DEVELOPER_DIR at Xcode.app (CI runners have Xcode selected already).
set -euo pipefail

cd "$(dirname "$0")/.."
[ -d upstream ] || { echo "no ./upstream — run scripts/fetch-upstream.sh first"; exit 1; }

for p in patches/*.patch; do
  echo "applying ${p}"
  patch -d upstream -p0 --forward < "$p"
done

if [ -z "${DEVELOPER_DIR:-}" ] && ! xcodebuild -version >/dev/null 2>&1; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

SYM="$(pwd)/upstream/build"
xcodebuild -project upstream/Skim.xcodeproj -target Skim -configuration Release build \
  CODE_SIGN_IDENTITY="-" SYMROOT="$SYM" | tail -5

APP="$SYM/Release/Skim.app"
[ -d "$APP" ] || { echo "build produced no app"; exit 1; }

# sanity: the pre-patch constant must be gone from the binary
python3 - "$APP/Contents/MacOS/Skim" <<'PY'
import struct, sys
data = open(sys.argv[1], 'rb').read()
assert data.find(struct.pack('<d', 1.8972)) == -1, "unpatched constant found in binary"
print("patch verified in binary")
PY

ditto -c -k --keepParent "$APP" Skim-plus.zip
echo "built: $APP"
echo "zipped: Skim-plus.zip"
