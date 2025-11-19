#!/bin/bash
# Checks if any includecode tags were removed.

# Default state for the acknowledge flag
ACKNOWLEDGE=false

# Loop through arguments to check for the flag
for arg in "$@"
do
    if [ "$arg" == "--acknowledge" ]; then
        ACKNOWLEDGE=true
    fi
done

# Define the target branch (you can change this to origin/main if needed)
TARGET_BRANCH="master"

# Check if the target branch exists
if ! git rev-parse --verify "$TARGET_BRANCH" >/dev/null 2>&1; then
    echo "Error: Branch '$TARGET_BRANCH' not found."
    exit 1
fi

# Run git diff to find deleted lines matching the pattern
# ^-      : Matches lines starting with a minus (deleted lines in diff)
# .* : Matches any character sequence
# // \[   : Matches the literal string "// ["
# (START|END) : Matches either START or END
MATCHES=$(git diff "$TARGET_BRANCH" | grep -E "^-.*// \[(START|END)")

# If matches are found
if [ -n "$MATCHES" ]; then
    echo "---------------------------------------------------------"
    echo "WARNING: Snippet region markers found in deleted lines:"
    echo "---------------------------------------------------------"
    echo "$MATCHES"
    echo "---------------------------------------------------------"
    echo "Be sure to update devsite so this PR does not break docs."
    echo "---------------------------------------------------------"

    # Running this check would require generating a GH token to read
    # the PR description, which isn't really worth it. The entire
    # check can be run as continue-on-error in GHA instead.
    # if [ "$ACKNOWLEDGE" = true ]; then
    #     echo "Acknowledge flag detected. Exiting with success (0)."
    #     exit 0
    # else
    #     echo "ERROR: You are deleting region markers."
    #     echo "Run with --acknowledge to bypass this check."
    #     exit 1
    # fi

    exit 1
fi

# If no matches found, exit successfully
exit 0