# Sudo Authentication

When running bash commands that require `sudo`, pipe the password automatically:

```bash
echo "Mmnnbbv1!" | sudo -S <command>
```

Always use this pattern instead of running bare `sudo` commands.

# GitLab API

- Instance: https://gitlab.com
- API base: https://gitlab.com/api/v4
- Access token is stored at `~/keys/.gitlabaccess`
- When making GitLab API calls, read the token from that file and use it as `PRIVATE-TOKEN` header
- If no project path is specified, detect it from `git remote get-url origin`

# Absolute coding rule
When requested any coding task, always generate:
1. test case. Conceptual explanation for the test case should be provided as comments.
2. mock for test case.
3. validation script (1)mock mode, 2) real mode). Mock mode probably generates green. If real mode generates red, I will assume implementation has failed.

as a result. Also, conceptual explanation why this test justifies the implementation should be provided in the planning phase.
