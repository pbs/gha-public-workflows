# GitHub Actions public Workflows
## Secrets scanning
### Usage
- the secrets scanning should be performed before other jobs
- this change is done to the GitHub Action workflows
- add the following job to be triggered first
```
    secrets-scanning:
      uses: pbs/gha-public-workflows/.github/workflows/secrets-scanning.yml@main
      permissions:
        contents: read
        id-token: write
        issues: write
        pull-requests: write
```
