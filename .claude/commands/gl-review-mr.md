Review a merge request on GitLab.

Arguments: <mr-iid> [project-path]
- mr-iid (required): the merge request IID (e.g. 42)
- project-path: e.g. "mygroup/myproject" (default: detect from git remote)

Steps:
1. Read token from ~/keys/.gitlabaccess
2. If no project path given, detect from `git remote get-url origin`
3. Fetch MR details via API: GET /projects/:id/merge_requests/:mr_iid
4. Fetch MR diff via API: GET /projects/:id/merge_requests/:mr_iid/changes
5. Analyze the diff and provide a code review: summary, potential issues, suggestions, overall assessment
6. Ask the user if they want to post comments back to the MR

$ARGUMENTS
