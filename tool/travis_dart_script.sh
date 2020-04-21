#!/bin/bash

set -e

declare -ar PROJECT_NAMES=(
    "packages/dartpad_test" \
)

for PROJECT_NAME in "${PROJECT_NAMES[@]}"
do
    echo "== Testing '${PROJECT_NAME}'"
    pushd "${PROJECT_NAME}"

    # Grab packages.
    pub get

    # Run the analyzer to find any static analysis issues.
    dartanalyzer --fatal-infos --fatal-warnings ./

    # Run the formatter on all the dart files to make sure everything's linted.
    dartfmt -n ./lib --set-exit-if-changed

    # Run the actual tests.
    pub run test test/dartpad_test_test.dart

    popd
done

echo "-- Success --"