# PBS GitHub Actions Templates
## **Description**
### This is a collection of GitHub Actions templates managed by the PLOPS team (and friends) and cover various workflow scenarios like building/testing/publishing docker images, deploying/updating services into AWS ECS or running commands
## **Features**
| feature | description | template(s) |
| --- | --- | --- |
| `Slack updates` | Send a Slack jobs status message to a channel and update it in real-time | `all` |
| `AWS login via OIDC roles` | Login into AWS using OIDC roles (created separately) | `all` |
| `AWS ECR login` | Login into AWS ECR | `all` |
| `Secrets scanning` | Scan for secrets inside the code | `docker-build-push` |
| `Before action commands` | Commands for preparing the environment | `all` |
| `After action commands` | Commands for tearing down the environment | `all` |
| `Docker build, test and push` | Build, test and push Docker images to AWS ECR; caching is enabled by default | `docker-build-push` |
| `AWS ECS deploy` | Deploy or update AWS ECS service | `ecs-deploy` |
| `Run shell commands` | Run shell commands | `run-commands` |
| `SonarQube code quality` | Scan and publish code quality to SonarQube | `docker-build-push` |
| `Test results parser` | Parse and publish test results to the GitHub Actions workflow | `docker-build-push, run-commands` |
| `Package dependency tracker` | Create SBOM (software bill of materials) from the docker image and publish to Dependency Tracker (WIP) | `docker-build-push` |

## **Prerequisites**
### Create the team OIDC roles
- one role for each account
- permissions should be granular and minimum per required actions
- should be created via a ticket to the PLOPS team (CAT board)
- more details - WIP
### Add secrets and environment variables
- secrets should be only passwords, tokens, keys, etc
- environment variables need to be set per environment (qa, staging, prod, etc)

| variable | description | scope |
| --- | --- | --- |
| `APP_NAME` | The application (service) name, including the environment (ex: app-test) | per env |
| `AWS_ACCOUNT` | AWS account ID | env |
| `AWS_OIDC_ROLE` | OIDC role name | account |
| `AWS_REGION` | AWS region name (ex: us-east-1) | env, global |
| `SLACK_CHANNEL_ID` | Slack channel ID | env, global |
| `SONAR_HOST_URL` | SonarQube host url | global |

| secret | description | scope |
| --- | --- | --- |
| `SLACK_BOT_TOKEN` | Slack bot token with access to the *SLACK_CHANNEL_ID* | global |
| `SONAR_TOKEN` | SonarQube token | global |

## **Templates**
- you can use multiple jobs in the same workflow
- if dependency is required between the jobs, use [needs](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idneeds)
## Base workflow (no jobs)
```yaml
name: Workflow example

on:
  workflow_dispatch:
  pull_request:
    types:
      - opened
      - reopened

permissions:
  id-token: write
  contents: read
```

## Docker Build / Test / Push
#### *Build, test and push Docker images*
### Usage
```yaml
jobs:
    build: 
      uses: pbs/gha-public-workflows/.github/workflows/docker-build-push.yml@main
      secrets: inherit
      with:
        env: test
        image_name: image-test
        image_build_tag: latest
        image_test_tag: test
        test_command: |
          echo "add commands that tests the image"
          docker run -t image-test:test echo "add another command ran inside the container"
```
<!-- action-docs-inputs source="./.github/workflows/docker-build-push.yml" -->
### Inputs

| name | description | type | required | default |
| --- | --- | --- | --- | --- |
| `env` | <p>Environment</p> | `string` | `true` | `""` |
| `before_command` | <p>(Optional) Command to prepare the environment</p> | `string` | `false` | `""` |
| `test_command` | <p>Command to test the application</p> | `string` | `false` | `""` |
| `after_command` | <p>(Optional) Command to teardown the environment</p> | `string` | `false` | `""` |
| `assume_aws_role` | <p>Assume AWS role</p> | `boolean` | `false` | `true` |
| `ecr_login` | <p>Login to ECR</p> | `boolean` | `false` | `true` |
| `immutable` | <p>Repository is immutable</p> | `boolean` | `false` | `false` |
| `secrets_scan` | <p>Scan code for secrets before build</p> | `boolean` | `false` | `true` |
| `sbom` | <p>Retrieve and push the Docker image SBOM</p> | `boolean` | `false` | `false` |
| `image_name` | <p>Docker image name</p> | `string` | `true` | `""` |
| `image_build_tag` | <p>Docker image build tag</p> | `string` | `false` | `latest` |
| `image_test_tag` | <p>Docker image test tag</p> | `string` | `false` | `test` |
| `dockerfile` | <p>Path to the Dockerfile</p> | `string` | `false` | `./Dockerfile` |
| `context` | <p>Build context for Docker</p> | `string` | `false` | `.` |
| `parser` | <p>Publish test results using JUnit Parser</p> | `boolean` | `false` | `false` |
| `report_paths` | <p>JUnit Parser report paths</p> | `string` | `false` | `outdist/*.xml` |
| `sonarqube` | <p>Submit code coverage to Sonarqube</p> | `boolean` | `false` | `false` |
<!-- action-docs-inputs source="./.github/workflows/docker-build-push.yml" -->

### ECS Deploy
#### *Deploy or update an AWS ECS service*
#### Usage
```yaml
jobs:
    deploy:
      uses: pbs/gha-public-workflows/.github/workflows/ecs-deploy.yml@main
      secrets: inherit
      with:
        env: test
        ecs_cluster: test-cluster
        ecs_service: test-service
        image_name: test-templates
        image_tag: latest
```
<!-- action-docs-inputs source="./.github/workflows/ecs-deploy.yml" -->
### Inputs

| name | description | type | required | default |
| --- | --- | --- | --- | --- |
| `env` | <p>Environment</p> | `string` | `true` | `""` |
| `name` | <p>Deployment name</p> | `string` | `false` | `""` |
| `before_command` | <p>(Optional) Command to prepare the environment</p> | `string` | `false` | `""` |
| `after_command` | <p>(Optional) Command to teardown the environment</p> | `string` | `false` | `""` |
| `assume_aws_role` | <p>Assume AWS role</p> | `boolean` | `false` | `true` |
| `ecr_login` | <p>Login to ECR</p> | `boolean` | `false` | `true` |
| `ecs_cluster` | <p>ECS cluster name</p> | `string` | `true` | `""` |
| `ecs_service` | <p>ECS service name</p> | `string` | `true` | `""` |
| `image_name` | <p>Docker image name</p> | `string` | `true` | `""` |
| `image_tag` | <p>Docker image tag</p> | `string` | `false` | `latest` |
| `timeout` | <p>ECS deploy timeout(seconds)</p> | `string` | `false` | `600` |
<!-- action-docs-inputs source="./.github/workflows/ecs-deploy.yml" -->

### Run Commands
#### *Run shell commands*
#### Usage
```yaml
jobs:
    run:
      uses: pbs/gha-public-workflows/.github/workflows/run-commands.yml@main
      secrets: inherit
      with:
        env: test
        name: testing123
        before_command: |
          echo "add optional commands that set up the environment prior to the build"
        command: |
          echo "main commands to be ran"
        after_command: |
          echo "add optional commands that cleans up the environment"
```
<!-- action-docs-inputs source="./.github/workflows/run-commands.yml" -->
### Inputs

| name | description | type | required | default |
| --- | --- | --- | --- | --- |
| `env` | <p>Environment</p> | `string` | `true` | `""` |
| `name` | <p>Command name</p> | `string` | `true` | `""` |
| `before_command` | <p>(Optional) Command to prepare the environment</p> | `string` | `false` | `""` |
| `command` | <p>Command to run</p> | `string` | `false` | `""` |
| `after_command` | <p>(Optional) Command to teardown the environment</p> | `string` | `false` | `""` |
| `assume_aws_role` | <p>Assume AWS role</p> | `boolean` | `false` | `true` |
| `ecr_login` | <p>Login to ECR</p> | `boolean` | `false` | `true` |
| `parser` | <p>Publish test results using JUnit Parser</p> | `boolean` | `false` | `false` |
| `report_paths` | <p>JUnit Parser report paths</p> | `string` | `false` | `outdist/*.xml` |
<!-- action-docs-inputs source="./.github/workflows/run-commands.yml" -->

### Secrets scanning
- the secrets scanning should be performed before other jobs
- this change is done to the GitHub Action workflows which run on push to feature branch or pull request to default branch
- add the following job to be triggered first
#### Usage
```
jobs:
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
