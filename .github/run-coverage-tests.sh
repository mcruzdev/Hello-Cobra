#!/bin/bash
# =============================================================================
#  Test Script to Run Go Test and Check 100% Coverage
# =============================================================================
#  This script WILL FAIL if the coverage rate is NOT "100%". To show where to
#  fix/cover then specify '-v' or '--verbose' option.
#
#  Requirements:
#    - go-carpet: https://github.com/msoap/go-carpet

# -----------------------------------------------------------------------------
#  Constants
# -----------------------------------------------------------------------------
PATH_DIR_PARENT="$(dirname "$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)")"
SUCCESS=0
FAILURE=1
TRUE=0
FALSE=1

# -----------------------------------------------------------------------------
#  Functions
# -----------------------------------------------------------------------------
# indentStdIn indents the STDIN given to the function
function indentStdIn() {
    indent="\t"
    while read -r line; do
        echo -e "${indent}${line}"
    done
    echo
}

# isModeVerbose just returns a bool whether it's in verbose
# mode or not.
function isModeVerbose() {
    if [ "$mode_verbose" -eq 0 ]; then
        return $TRUE
    fi

    return $FALSE
}

function runGoCarpet() {
    if ! which go-carpet >/dev/null; then
        echo '* aborted'
        echo >&2 '  * Command "go-carpet" not found.'
        echo >&2 '    "go-carpet" is needed to view the test coverage area in the terminal.'
        echo >&2 '    To install see: https://github.com/msoap/go-carpet'

        exit $FAILURE
    fi

    go-carpet
}

# runTests runs unit tests.
# If verbose option is provided then it will run the tests in verbose mode and
# measures the coverage. If the coverage is lower than 100% then it will fail
# and show the cover area as well.
function runTests() {
    description="${1:?'Test description missing.'}"
    path_dir="${2:?'Path is missing'}"
    name_file_coverage='coverage.out'

    echo "- Unit test: ${description}"
    # Run tests
    if isModeVerbose; then
        echo '  * Running in verbose mode.'
        go test -timeout 30s -cover -v -coverprofile "$name_file_coverage" "$path_dir" | indentStdIn
    else
        echo '  * Running in regular mode.'
        echo '  * Use "-v" or "--verbose" option for verbose output.'
        go test -timeout 30s -cover -coverprofile "$name_file_coverage" "$path_dir" | indentStdIn
    fi

    # Get coverage details
    cover=$(go tool cover -func="$name_file_coverage")

    if isModeVerbose; then
        echo '- Coverage details'
        echo "$cover" | indentStdIn
    fi

    # Get coverage rate
    coverage=$(echo "$cover" | grep total | awk '{print $3}')

    if [ "$coverage" = "100.0%" ]; then
        echo 'Success! Coverage: 100%'
        return $SUCCESS
    else
        # Displays where to cover, if the total coverage wasn't 100%
        if isModeVerbose; then
            echo '- Cover area'
            runGoCarpet | indentStdIn
        fi
        echo >&2 "Coverage failed: Did not cover 100% of the statements. Coverage: ${coverage}"
        return $FAILURE
    fi
}

# -----------------------------------------------------------------------------
#  Setup
# -----------------------------------------------------------------------------
# Detect verbose option
mode_verbose=$FALSE
echo "${@}" | grep -e "-v" -e "--verbose" >/dev/null && {
    mode_verbose=$TRUE
}

# -----------------------------------------------------------------------------
#  Main
# -----------------------------------------------------------------------------
set -eu
set -o pipefail

echo "Moving current path to: ${PATH_DIR_PARENT}"
cd "$PATH_DIR_PARENT"
echo "Current path is: $(pwd)"
runTests "Testing all the packages" "./..."