#!/bin/bash

# Define repository URLs and paths to version files
SOURCE_REPO_URL="https://github.com/username/source-repo.git"
TARGET_REPO_URL="https://github.com/username/target-repo.git"
SOURCE_FILE_PATH="path/to/source/version/file"  # The file that contains the version (e.g., version.txt)
TARGET_FILE_PATH="path/to/target/version/file"  # The file where you need to replace the version (e.g., package.json)
VERSION_REGEX='[0-9]+\.[0-9]+\.[0-9]+'        # Regex to find the version number (customize if needed)

# Create temporary directories for the repositories
SOURCE_REPO_DIR=$(mktemp -d)
TARGET_REPO_DIR=$(mktemp -d)

# Step 1: Clone the source repository
echo "Cloning the source repository..."
git clone $SOURCE_REPO_URL $SOURCE_REPO_DIR/source-repo

# Step 2: Extract the version from the source file (Assuming a version like X.Y.Z in the source file)
echo "Extracting the version from the source file..."
cd $SOURCE_REPO_DIR/source-repo
VERSION=$(grep -Eo $VERSION_REGEX $SOURCE_FILE_PATH | head -n 1)
echo "Found version: $VERSION"

if [[ -z "$VERSION" ]]; then
  echo "Error: Could not find a version in the source file."
  exit 1
fi

# Step 3: Clone the target repository
echo "Cloning the target repository..."
git clone $TARGET_REPO_URL $TARGET_REPO_DIR/target-repo

# Step 4: Replace the version in the target file
echo "Replacing the version in the target file..."
cd $TARGET_REPO_DIR/target-repo

# Check if the target file exists
if [[ ! -f $TARGET_FILE_PATH ]]; then
  echo "Error: Target file does not exist."
  exit 1
fi

# Use sed to find and replace the version in the target file
sed -i "s/$VERSION_REGEX/$VERSION/g" $TARGET_FILE_PATH

# Step 5: Verify the replacement
echo "Verifying the updated version..."
grep -Eo $VERSION_REGEX $TARGET_FILE_PATH

# Step 6: Create a new branch for the version update
BRANCH_NAME="update-version-to-$VERSION"
echo "Creating a new branch: $BRANCH_NAME"
git checkout -b $BRANCH_NAME

# Step 7: Add, commit, and push the changes
git add $TARGET_FILE_PATH
git commit -m "Update version to $VERSION"
echo "Pushing the branch to the remote repository..."
git push origin $BRANCH_NAME

# Step 8: Create a Pull Request using GitHub CLI (Ensure 'gh' is installed and authenticated)
echo "Creating a Pull Request..."
gh pr create --title "Update version to $VERSION" --body "This PR updates the version to $VERSION." --head $BRANCH_NAME --base main

# Step 9: Clean up temporary directories
echo "Cleaning up..."
rm -rf $SOURCE_REPO_DIR
rm -rf $TARGET_REPO_DIR

echo "Version update PR created successfully!"
