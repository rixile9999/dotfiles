Create a merge request on GitLab for the current branch.

Arguments: [target-branch]
- target-branch: branch to merge into (default: main)

Steps:
1. Read token from ~/keys/.gitlabaccess
2. Detect project path from `git remote get-url origin`
3. Get current branch with `git branch --show-current`
4. Run `git log` and `git diff` against target branch to understand changes
5. Draft a concise MR title and description based on the changes
6. Push current branch if not already pushed
7. Create MR via API: POST /projects/:id/merge_requests with source_branch, target_branch, title, description
8. Show the MR URL to the user

$ARGUMENTS
