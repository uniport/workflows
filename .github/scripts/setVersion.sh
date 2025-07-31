#!/usr/bin/env bash

set -EeuCo pipefail
shopt -s globstar

function printUsage {
    cat <<EOF
    Provide single parameter for the new version, e.g. 1.2.3

    Usage:
            $0 1.2.3
            or
            $0.1.2.3-SNAPSHOT
EOF
}

if [[ "$#" -eq 0 ]]; then
    printUsage
    exit
fi

readonly newVersion=$1
readonly newVersionWithoutSnapshot
newVersionWithoutSnapshot=$(sed "s/-SNAPSHOT//" <<<"${newVersion}")

# Update pom files
mvn versions:set \
  -DnewVersion="${newVersion}" \
  -DprocessFromLocalAggregationRoot=true \
  -DprocessParent=true \
  -DgenerateBackupPoms=false \
  -DprocessProject=true

# Update package.json / package-lock.json
# Strip the -SNAPSHOT suffix if its part of the new version
files=()
while IFS="" read -r line; do files+=("$line"); done < <(find . -maxdepth 5 \( -name package.json -o -name package-lock.json \))

echo "Number of frontend files to update: ${#files[@]}"
for f in "${files[@]}"; do
    echo "Updating file: $f"
    # Sed replaces potentially too many occurences, hence we stick to jq
    #sed -i 's/"version": .*"/"version": '\"${newVersionWithoutSnapshot}\"'/g' $f

    jq --arg version "${newVersionWithoutSnapshot}" '.version = $version' "$f" >"${f}.tmp"
    mv "${f}.tmp" "$f"

    # Update self-referencing entry in package-lock.json
    if [[ "${f}" == *package-lock.json ]]
      then
        echo "Updating self-reference in package-lock.json"
        jq --arg version "${newVersionWithoutSnapshot}" '.packages."".version= $version' "$f" >"${f}.tmp"
        mv "${f}.tmp" "$f"
    fi
done
