#!/bin/bash
# Export the Skim source for a given release version from upstream SVN.
# Usage: fetch-upstream.sh <version>        e.g. fetch-upstream.sh 1.7.15
# Exports into ./upstream/ (wiped first).
set -euo pipefail

VERSION="${1:?usage: fetch-upstream.sh <version> (e.g. 1.7.15)}"
TAG="REL_${VERSION//./_}"
URL="https://svn.code.sf.net/p/skim-app/code/tags/${TAG}"

command -v svn >/dev/null || { echo "svn not found (brew install subversion)"; exit 1; }

svn info "$URL" >/dev/null 2>&1 || { echo "upstream tag ${TAG} not found at ${URL}"; exit 1; }

rm -rf upstream
echo "exporting ${TAG} ..."
svn export -q "$URL" upstream
echo "exported to ./upstream"
