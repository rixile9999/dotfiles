List recent CI/CD pipelines from a GitLab project.

Arguments: [project-path]
- project-path: e.g. "mygroup/myproject" (default: detect from git remote)

Steps:
1. Read token from ~/keys/.gitlabaccess
2. If no project path given, detect from `git remote get-url origin`
3. URL-encode the project path
4. Fetch pipelines via API: GET /projects/:id/pipelines?per_page=15
5. Display as a readable table: ID, status, ref (branch), source, created date, web_url

$ARGUMENTS
