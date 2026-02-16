List merge requests from a GitLab project.

Arguments: [project-path] [state]
- project-path: e.g. "mygroup/myproject" (default: detect from git remote)
- state: opened, closed, merged, all (default: opened)

Steps:
1. Read token from ~/keys/.gitlabaccess
2. If no project path given, detect from `git remote get-url origin`
3. URL-encode the project path (replace `/` with `%2F`)
4. Fetch MRs via API: GET /projects/:id/merge_requests?state=STATE&per_page=20
5. Display as a readable table: IID, title, author, state, created date, web_url

$ARGUMENTS
