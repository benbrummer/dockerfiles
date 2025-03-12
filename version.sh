#!/bin/bash
VERSION=$(cat version.txt | tr -d v)
MAJOR="$(echo "${VERSION}" | cut -d. -f1)"
MINOR=${MAJOR}."$(echo "${VERSION}" | cut -d. -f2)"

echo "Current version: ${VERSION}"

if [ "${GITHUB_ACTIONS}" ]; then
    echo "VERSION=${VERSION}" >> "{$GITHUB_ENV}"
    echo "MAJOR=${MAJOR}" >> "{$GITHUB_ENV}"
    echo "MINOR=${MINOR}" >> "{$GITHUB_ENV}"
fi
