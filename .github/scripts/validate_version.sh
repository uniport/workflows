#!/bin/bash
set -eCo pipefail

VERSION="$1"

# Regex for version format: semver-date-build_number-git_short_sha
# semver: e.g., 9.5.0
# date: YYYYMMDDHHMM, e.g., 202504221620
# build number: numeric, e.g., 1321
# git short sha: 7-8 hex chars, e.g., d65d211b
REGEX="^[0-9]+\.[0-9]+\.[0-9]+-[0-9]{12}-[0-9]+-[0-9a-f]{7,8}$"

if [[ ! $VERSION =~ $REGEX ]]; then
  echo "Error: Version '$VERSION' does not match the expected format 'semver-date-build_number-git_short_sha' (e.g., 9.5.0-202504221620-1321-d65d211b)"
  exit 1
else
  echo "Version '$VERSION' is valid"
fi
