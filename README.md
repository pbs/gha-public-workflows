# GitHub Actions public workflows
## Secrets scanning
### Usage
- the secrets scanning should be performed before other jobs
- this change is done to the GitHub Action workflows which run on push to feature branch or pull request to default branch
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
- add this to the rest of the jobs to make them dependent on the secrets-scanning job
```
    job1:
      needs: secrets-scanning
      ...
    job2:
      needs: secrets-scanning
      ...
```
