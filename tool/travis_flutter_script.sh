#!/bin/bash

set -e

# Backs up one directory at a time, looking for one called "flutter". Once it
# finds that directory, an absolute path to it is returned.
function getFlutterPath() {
    local path=""
    local counter=0

    while [[ "${counter}" -lt 10 ]]; do
        [ -d "${path}flutter" ] && echo "$(pwd)/${path}flutter" && return 0
        let counter++
        path="${path}../"
    done
}

readonly LOCAL_SDK_PATH=$(getFlutterPath)

if [ -z "${LOCAL_SDK_PATH}" ]
then
    echo "Failed to find the Flutter SDK!"
    exit 1
fi

echo "Flutter SDK found at ${LOCAL_SDK_PATH}"

declare -ar PROJECT_NAMES=(
    "packages/dartpad_flutter_test" \
)

for PROJECT_NAME in "${PROJECT_NAMES[@]}"
do
    echo "== Testing '${PROJECT_NAME}' on Flutter's ${FLUTTER_VERSION} channel =="
    pushd "${PROJECT_NAME}"

    # Run the analyzer to find any static analysis issues.
    "${LOCAL_SDK_PATH}/bin/flutter" analyze

    # Run the formatter on all the dart files to make sure everything's linted.
    "${LOCAL_SDK_PATH}/bin/flutter" format -n --set-exit-if-changed .

    # Run the actual tests.
    "${LOCAL_SDK_PATH}/bin/flutter" test

    popd
done

echo "-- Success --"