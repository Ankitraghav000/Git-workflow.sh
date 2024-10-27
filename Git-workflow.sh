#!/bin/bash

# Function to display branches
function list_branches {
    echo "Available branches:"
    git branch
}

# Function to edit file in Vim
function edit_file_in_vim {
    echo "Select file to edit (provide full name with extension):"
    ls
    read -r file_name
    vim "$file_name"
}

# Step 1: Clone the repository
echo "Enter the Git repository link to clone:"
read -r repo_link
git clone "$repo_link"

# Extract the repository name from the URL
repo_name=$(basename "$repo_link" .git)

# Navigate into the cloned repository directory
cd "$repo_name" || exit

# Confirm to the user that they are in the cloned repository directory
echo "Now you are in the $repo_name repository."

# Step 2: Ask to create a new file
echo "Do you want to create a new file? (y/n)"
read -r create_file
if [ "$create_file" = "y" ]; then
    echo "Enter the name of the new file (with extension):"
    read -r file_name
    touch "$file_name"
    code "$file_name"

    echo "Did you complete adding code in Visual Studio Code? (y/n)"
    read -r completed_code
    if [ "$completed_code" = "y" ]; then
        git add "$file_name"
        echo "Enter a commit message for this new file:"
        read -r commit_message
        git commit -m "$commit_message"
    fi
fi

# Step 3: Branch creation and switching
echo "Do you want to create a new branch? (y/n)"
read -r create_branch
if [ "$create_branch" = "y" ]; then
    echo "Enter the name of the new branch:"
    read -r branch_name
    git checkout -b "$branch_name"
    edit_file_in_vim

    git add .
    echo "Enter a commit message for changes in $branch_name:"
    read -r commit_message
    git commit -m "$commit_message"
fi

# Step 4: Option to create another branch and edit
while true; do
    echo "Do you want to create another branch? (y/n)"
    read -r create_another_branch
    if [ "$create_another_branch" = "y" ]; then
        echo "Enter the name of the new branch:"
        read -r new_branch_name
        git checkout -b "$new_branch_name"
        edit_file_in_vim
        git add .
        echo "Enter a commit message for changes in $new_branch_name:"
        read -r commit_message
        git commit -m "$commit_message"
    else
        break
    fi
done

# Step 5: Merging branches
echo "Do you want to merge branches? (y/n)"
read -r merge_branches
if [ "$merge_branches" = "y" ]; then
    list_branches
    echo "Enter the branch you want to merge into (typically 'main' or 'master'):"
    read -r base_branch
    git checkout "$base_branch"

    echo "Enter the branch you want to merge from:"
    read -r branch_to_merge
    git merge "$branch_to_merge" -m "Merging $branch_to_merge into $base_branch"
fi

# Step 6: Pull the latest changes
echo "Do you want to pull the latest changes from remote? (y/n)"
read -r pull_changes
if [ "$pull_changes" = "y" ]; then
    git pull origin "$(git branch --show-current)"
fi

# Step 7: Push to remote and create a Pull Request (PR)
echo "Do you want to push your changes to the remote repository? (y/n)"
read -r push_to_remote

if [ "$push_to_remote" = "y" ]; then
    git push origin "$(git branch --show-current)"

    # Check if the last command was successful
    if [ $? -eq 0 ]; then
        echo "Automation completed!"
    else
        echo "Automation not completed: push failed."
    fi
else
    echo "Push to remote repository was skipped."
fi
