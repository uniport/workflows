#!/usr/bin/env bash

# Setup your auth credentials:
# $ export JIRA_BASIC_AUTH_TOKEN=$(echo -n 'YOUR_USERNAME:YOUR_TOKEN' | base64 -w0 -)
# e.g. 'florian.buetler@inventage.com:ATAT...9BCF429'
#
# The JIRA Api is documented here: https://docs.atlassian.com/software/jira/docs/api/REST/9.4.1/#api/2/version-getRemoteVersionLinksByVersionId
set -EeuCo pipefail

declare -r API_URL='https://inventage-all.atlassian.net/rest/api/2'
declare -r PROJECT_KEY='PORTAL'
declare -r BASIC_AUTH_TOKEN=${JIRA_BASIC_AUTH_TOKEN:-""}

function printUsage {
    cat <<EOF
    Provide the component name, the tag and the full version as arguments

    Usage:
            $0 Portal-Messaging 6.1.0 6.1.0-202305250929-344-6b6afe9
EOF
}

function getVersionId() {
    local versionName=$1
    curl --silent --fail --show-error \
        -H "Authorization: Basic ${BASIC_AUTH_TOKEN}" \
        ${API_URL}/project/${PROJECT_KEY}/versions |
        jq -r ".[] | select(.name == \"${versionName}\") | .id"
}

function updateNEXTVersion() {
    # Update the name of the next version
    local id=$1

    curl \
        -X PUT \
        -H "Authorization: Basic ${BASIC_AUTH_TOKEN}" \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        --url "${API_URL}/version/${id}" \
        --data "{
            \"name\": \"${COMPONENT} ${NEW_VERSION}\",
            \"description\": \"${NEW_VERSION_DESCRIPTION}\"
        }"
}

function createNewVersion() {
    local versionName=$1

    curl \
        -X POST \
        -H "Authorization: Basic ${BASIC_AUTH_TOKEN}" \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        --url "${API_URL}"/version \
        --data "{
            \"name\": \"${versionName}\",
            \"project\": \"${PROJECT_KEY}\"
        }"
}

function releaseVersion() {
    local versionId=$1
    local moveUnfixedIssuesTo=$2
    local releaseDate
    releaseDate=$(LC_ALL=en_US.utf8 date +%F)

    curl \
        -X PUT \
        -H "Authorization: Basic ${BASIC_AUTH_TOKEN}" \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        --url "${API_URL}/version/${versionId}" \
        --data "{
            \"released\": true,
            \"moveUnfixedIssuesTo\": \"${moveUnfixedIssuesTo}\",
            \"releaseDate\": \"${releaseDate}\"
        }"
}

if [[ "$#" -lt 3 ]]; then
    printUsage
    exit
fi

declare -r COMPONENT="$1"
declare -r NEW_VERSION="$2"
declare -r NEW_VERSION_DESCRIPTION="$3"

# The workflow is as follows:
# 1) find current -NEXT version
# 2) update said version with description & new name
# 3) create another -NEXT version
# 4) update previous with (the one from 2) to status release and move open tickets to new -NEXT version

idNEXT=$(getVersionId "${COMPONENT} NEXT")
readonly idNEXT
if [ -z "${idNEXT}" ]; then
    echo "Empty id. Have you properly setup authentication?"
    exit 1
fi
echo "--> ..-NEXT version has id: ${idNEXT}"

# Update name of NEXT version to 3.1.0
echo "--> Updating name & description for versionId=${idNEXT}"
updateNEXTVersion "${idNEXT}"

# Create new -NEXT version
echo "--> Creating new -NEXT version"
createNewVersion "${COMPONENT} NEXT"
newNextVersion=$(getVersionId "${COMPONENT} NEXT")
readonly newNextVersion

# Release the updated version
releaseVersion "${idNEXT}" "${newNextVersion}"
