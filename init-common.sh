#!/bin/bash

# Branch and submodule details
BRANCH="dev-common"
SUBMODULE_PATH="dev-common-ref"  # Replace with the path where the submodule should be placed
REPO_URL="https://github.com/LouisVuitton/crm_world.git"  # Replace with the repository URL of the submodule

# Check if the submodule already exists
if [ -d "$SUBMODULE_PATH" ]; then
    echo "Submodule already exists, updating..."
    # Change to the submodule directory
    cd "$SUBMODULE_PATH"
    # Ensure the submodule is on the correct branch
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
    # Go back to the main repository
    cd -
else
    echo "Adding submodule from branch '$BRANCH'..."
    git submodule add -f -b "$BRANCH" "$REPO_URL" "$SUBMODULE_PATH"
fi

# Initialize and update the submodule
git submodule init
git submodule update

# Commit the changes (optional)
git add .gitmodules "$SUBMODULE_PATH"
git commit -m "Add/Update submodule from branch '$BRANCH'"

echo "Submodule has been added/updated successfully."
