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

# Maven command variable that will be set based on availability
MVN_CMD=""

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

# Function to check if a command exists
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to initialize Maven command
function init_maven_command() {
    local mvnw_found=false
    local mvn_found=false

    # First, try to find the repository root and mvnw
    REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
    git_exit_code=$?

    if [[ $git_exit_code -eq 0 && -n "${REPO_ROOT}" ]]; then
        # We're in a git repository
        readonly MVNW_PATH="${REPO_ROOT}/mvnw"

        if [[ -f "${MVNW_PATH}" && -x "${MVNW_PATH}" ]]; then
            mvnw_found=true
            print_info "Found Maven wrapper at: ${MVNW_PATH}"
        fi
    fi

    # Check for globally installed mvn
    if command_exists mvn; then
        mvn_found=true
        print_info "Found globally installed Maven: $(which mvn)"
    fi

    # Decide which Maven command to use based on preference and availability
    if [[ "${mvnw_found}" == true ]]; then
        MVN_CMD="${MVNW_PATH}"
        print_success "Using Maven wrapper from repository"
    elif [[ "${mvn_found}" == true ]]; then
        MVN_CMD="mvn"
        print_success "Using globally installed Maven"
    else
        print_error "Error: Neither maven wrapper (mvnw) nor globally installed maven (mvn) found!"
        print_error "Please ensure either:"
        print_error "  1. You're in a Git repository with mvnw in the root, or"
        print_error "  2. Maven is installed globally and available in PATH"
        exit 1
    fi
}

# Updates all parent version in pom.xml files.
function updateParentVersions() {
    local version="$1"

    "${MVN_CMD}" -q build-helper:parse-version versions:set \
        -DnewVersion="${version}" \
        -DprocessFromLocalAggregationRoot=true \
        -DprocessParent=true \
        -DgenerateBackupPoms=false \
        -DprocessProject=true
}

# Prints the project version of the maven module in the current directory.
function getModuleVersion() {
    "${MVN_CMD}" help:evaluate -Dexpression=project.version -q -DforceStdout
}

# Updates the version of a single module, this does not use the global version, only its suffix (build metadata)
function updateSingleModule() {
    "${MVN_CMD}" build-helper:parse-version versions:set \
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

    The script will automatically detect and use:
    - Maven wrapper (mvnw) from the repository root if available
    - Globally installed Maven (mvn) as fallback

    You can force the use of a specific Maven command by setting the FORCE_MVN_CMD environment variable:
            FORCE_MVN_CMD=mvn $0 1.2.3
            FORCE_MVN_CMD=/path/to/mvnw $0 1.2.3
EOF
}

# Main script starts here

if [[ "$#" -eq 0 ]]; then
    printUsage
    exit 1 # Exit with non-zero status code for usage error
fi

# Check if user wants to force a specific Maven command
if [[ -n "${FORCE_MVN_CMD}" ]]; then
    if command_exists "${FORCE_MVN_CMD}" || [[ -x "${FORCE_MVN_CMD}" ]]; then
        MVN_CMD="${FORCE_MVN_CMD}"
        print_success "Using forced Maven command: ${MVN_CMD}"
    else
        print_error "Error: Forced Maven command '${FORCE_MVN_CMD}' not found or not executable!"
        exit 1
    fi
else
    # Initialize Maven command (mvnw or mvn)
    init_maven_command
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

print_success "Version update completed successfully!"
