List your GitLab projects.

Arguments: [search-query]
- search-query: optional text to filter projects by name

Steps:
1. Read token from ~/keys/.gitlabaccess
2. If search query provided, fetch via API: GET /projects?membership=true&search=QUERY&per_page=20
3. If no query, fetch via API: GET /projects?membership=true&per_page=20&order_by=last_activity_at
4. Display as a readable table: ID, name, path_with_namespace, default_branch, web_url

$ARGUMENTS
