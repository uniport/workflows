#!/usr/bin/env bash

set -EeuCo pipefail
shopt -s globstar

function printUsage {
  cat <<EOF
    Provide single parameter for the new package version, e.g. 4.4.0-202307251410-244-fc44010

    Usage:
            $0 4.4.0-202307251410-244-fc44010
EOF
}

if [[ "$#" -eq 0 ]]; then
  printUsage
  exit
fi

# parameters
readonly PACKAGE_VERSION="$1"

# parse version
VERSION_REGEX="([0-9]+)\.([0-9]+)\.([0-9]+)(\-.*)"
MAJOR=$(echo "$PACKAGE_VERSION" | sed -rE "s/$VERSION_REGEX/\1/")
MINOR=$(echo "$PACKAGE_VERSION" | sed -rE "s/$VERSION_REGEX/\2/")
PATCH=$(echo "$PACKAGE_VERSION" | sed -rE "s/$VERSION_REGEX/\3/")
VERSION="${MAJOR}.${MINOR}.${PATCH}"

# increment minor/patch
NEXT_MINOR="${MINOR}"
NEXT_PATCH="${PATCH}"
if [[ "${PATCH}" -eq 0 ]]; then
    NEXT_MINOR="$(( MINOR + 1 ))"
else
    NEXT_PATCH="$(( PATCH + 1 ))"
fi
NEXT_VERSION="${MAJOR}.${NEXT_MINOR}.${NEXT_PATCH}"

CHANGELOG_FILE="CHANGELOG.md"

# to make the string templates readable
function replaceNewlinesWithLiteral() {
  echo "$1" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g'
}

function updateNexusLinks() {
  NEXUS_LINK_BOILERPLATE="\1$PACKAGE_VERSION\2"

  NEXUS3_LINK_PATTERN="(\[Artifacts\]\(https:\/\/nexus3\.inventage\.com.*search=version%3D%22)\?\?\?(%22)"

  sed -i -E "s,$NEXUS3_LINK_PATTERN,$NEXUS_LINK_BOILERPLATE,g" "$CHANGELOG_FILE"
}

function addNewUnreleasedSection() {
  CURRENT_DATE=$(date "+%Y-%m-%d")
  MARKDOWN_SECTION_HEADER=$(echo "$PACKAGE_VERSION" | sed -rE "s/([0-9]+\.[0-9]+\.[0-9]+)(\-.*)/[\1]\2 - $CURRENT_DATE/")

  NEXUS3_LINK_PATTERN="\[Artifacts\]\(https:\/\/nexus3\.inventage\.com.*search=version%3D%22.+?%22"

  # only add nexus 3 link if there are others
  NEXUS3_LINK=""
  NEXUS3_LINK_EXISTS=$(grep -E "$NEXUS3_LINK_PATTERN" "$CHANGELOG_FILE" || true)
  if [[ -n "$NEXUS3_LINK_EXISTS" ]]; then
    NEXUS3_LINK="[Artifacts](https:\/\/nexus3.inventage.com/#browse/search=version%3D%22???%22)"
  fi

  # add linebreaks if any is present
  LINE_SEPARATOR=""
  if [[ -n "$NEXUS3_LINK" ]]; then
    LINE_SEPARATOR="\n"
  fi

  UNRELEASED_MARKDOWN_SECTION_PATTERN="##\s?([0-9]+\.[0-9]+\.[0-9]+-)?\[(U|u)nreleased\].*"
  MARKDOWN_SECTION_BOILERPLATE=$(replaceNewlinesWithLiteral "## $NEXT_VERSION-[Unreleased] - ???
${LINE_SEPARATOR}${NEXUS3_LINK}${LINE_SEPARATOR}
## $MARKDOWN_SECTION_HEADER")

  sed -i -E "s,$UNRELEASED_MARKDOWN_SECTION_PATTERN,$MARKDOWN_SECTION_BOILERPLATE,g" "$CHANGELOG_FILE"
}

function addNewCompareLink() {
  # sed arguments:
  # 1: link base
  # 2: source branch value
  # 3: target branch value
  UNRELEASED_MARKDOWN_LINK_PATTERN='\[[Uu]nreleased\]:\s(https:\/\/github\.com\/uniport\/.*\/compare\/)(.*)\.\.\.(.*)'
  MARKDOWN_LINK_BOILERPLATE=$(replaceNewlinesWithLiteral "[unreleased]: \1$VERSION...\3
[$VERSION]: \1\2...$VERSION")
  sed -i -E "s,$UNRELEASED_MARKDOWN_LINK_PATTERN,$MARKDOWN_LINK_BOILERPLATE,g" "$CHANGELOG_FILE"
}

updateNexusLinks
addNewUnreleasedSection
addNewCompareLink
