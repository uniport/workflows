#!/usr/bin/env bash
# Utility script to update versions in pom.xml files
#
# The complexity of this process is due to the maven reactor containing modules with different versions.
#
# For all maven modules/pom files we want:
# - update the parent version
# - in case a module has its version explicitly set (api-graphql, api-kafka, etc.) we don't want to override it but
#   rather change its suffix (semver pre-release metadata), e.g. replace `-SNAPSHOT` with `-$versionSuffix` where $versionSuffix is a string containing
#   build metadata.

set -eCo pipefail

readonly NO_COLOR='\033[0m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'

# Determine the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
git_exit_code=$?
if [[ $git_exit_code -ne 0 || -z "${REPO_ROOT}" ]]; then
    print_error "Not inside a Git repository (or Git command failed). Ensure the script is run within a Git repository containing mvnw."
    exit 1
fi

# Construct the path to mvnw wrapper
readonly MVNW_PATH="${REPO_ROOT}/mvnw"

function print_info() {
    local msg="$1"
    echo -e "${BLUE}${msg}${NO_COLOR}"
}

function print_success() {
    local msg="$1"
    echo -e "${GREEN}${msg}${NO_COLOR}"
}

function print_error() {
    local msg="$1"
    echo -e "${RED}${msg}${NO_COLOR}"
}

# Updates all parent version in pom.xml files.
function updateParentVersions() {
    local version="$1"

    "${MVNW_PATH}" -q build-helper:parse-version versions:set \
        -DnewVersion="${version}" \
        -DprocessFromLocalAggregationRoot=true \
        -DprocessParent=true \
        -DgenerateBackupPoms=false \
        -DprocessProject=true
}

# Prints the project version of the maven module in the current directory.
function getModuleVersion() {
    "${MVNW_PATH}" help:evaluate -Dexpression=project.version -q -DforceStdout
}

# Updates the version of a single module, this does not use the global version, only its suffix (build metadata)
function updateSingleModule() {
    "${MVNW_PATH}" build-helper:parse-version versions:set \
        -DnewVersion="\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}-${suffix}" \
        -DgenerateBackupPoms=false \
        -DprocessProject=true \
        -DprocessParent=false
}

function getModules() {
    sed -n '/^ *<module>/s/^ *<module>\(.*\)<\/module>/\1/p' pom.xml | xargs
}

function updateModule() {
    local moduleVersion

    moduleVersion=$(getModuleVersion)

    if [[ "${moduleVersion}" != "${PROJECT_VERSION}" ]]; then
        print_info "Module version (=${moduleVersion}) is different than project version (=${PROJECT_VERSION})"
        updateSingleModule
    else
        print_info "Module has same version as project/parent - skipping version update"
    fi

    local subModules=($(getModules))

    if [[ "${#subModules[@]}" -gt 0 ]]; then
        print_info "Module has submodules:"
        printf '\t%s\n' "${subModules[@]}"

        for subModule in "${subModules[@]}"; do
            print_info "Inspecting sub module '${subModule}'"

            pushd "${subModule}"
            updateModule
            popd
        done
    else
        print_info "Module has no submodules"
    fi
}

function printUsage {
    cat <<EOF
    Provide single parameter for the new version, e.g. 1.2.3

    Usage:
            $0 1.2.3
            or
            $0 1.2.3-SNAPSHOT
EOF
}

if [[ "$#" -eq 0 ]]; then
    printUsage
    exit 1 # Exit with non-zero status code for usage error
fi

readonly newVersion="$1"
suffix=$(echo "$newVersion" | cut -d "-" -f 2-) # Use -f 2- to get all parts after the first hyphen
readonly suffix

print_info "Updating parent versions..."
updateParentVersions "${newVersion}"

PROJECT_VERSION=$(getModuleVersion)
readonly PROJECT_VERSION

print_info "Found project version: ${PROJECT_VERSION}"

modules=($(getModules))

if [[ "${#modules[@]}" -eq 0 ]]; then
    print_success "This project has no modules - skipping version update for modules"
    exit 0
fi

print_info "Project has the following modules:"
printf '\t%s\n' "${modules[@]}"

print_info "Found ${#modules[@]} potential pom files for version update"
for module in "${modules[@]}"; do
    print_info "Inspecting module: ${module}"
    pushd "${module}"
    updateModule
    popd
done
