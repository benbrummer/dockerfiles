#!/bin/bash
export VERSION="$(cat version.txt | tr -d v)"
export MAJOR="$(echo "${VERSION}" | cut -d. -f1)"
export MINOR="${MAJOR}.$(echo "${VERSION}" | cut -d. -f2)"
export URL="https://github.com/invoiceninja/invoiceninja/releases/download/v${VERSION}/invoiceninja.tar.gz"

echo "Current version: ${VERSION}"

if [ "${GITHUB_ACTIONS}" ]; then
    echo "VERSION=${VERSION}" >> "${GITHUB_ENV}"
    echo "MAJOR=${MAJOR}" >> "${GITHUB_ENV}"
    echo "MINOR=${MINOR}" >> "${GITHUB_ENV}"
    echo "URL=${URL}" >> "${GITHUB_ENV}"
    echo "VERSION=${VERSION}" >> "${GITHUB_OUTPUT}"
    echo "MAJOR=${MAJOR}" >> "${GITHUB_OUTPUT}"
    echo "MINOR=${MINOR}" >> "${GITHUB_OUTPUT}"
    echo "URL=${URL}" >> "${GITHUB_OUTPUT}"
fi
