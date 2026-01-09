#!/bin/bash
VERSION="$(cat version.txt | tr -d v)"
export VERSION

MAJOR="$(echo "${VERSION}" | cut -d. -f1)"
export MAJOR

MINOR="${MAJOR}.$(echo "${VERSION}" | cut -d. -f2)"
export MINOR

URL="https://github.com/invoiceninja/invoiceninja/releases/download/v${VERSION}/invoiceninja.tar.gz"
export URL

echo "Current version: ${VERSION}"

if [ "${GITHUB_ACTIONS}" ]; then
    {
        echo "VERSION=${VERSION}"
        echo "MAJOR=${MAJOR}"
        echo "MINOR=${MINOR}"
        echo "URL=${URL}"
        echo "VERSION=${VERSION}"
        echo "MAJOR=${MAJOR}"
        echo "MINOR=${MINOR}"
        echo "URL=${URL}"
    } >>"${GITHUB_OUTPUT}"
fi
