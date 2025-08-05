# Uniport Workflows

A collection of reusable workflows and composite actions to avoid duplicating the content of workflows in GitHub actions.

[![Main build](https://github.com/uniport/workflows/actions/workflows/main.yml/badge.svg)](https://github.com/uniport/workflows/actions/workflows/main.yml)

> [!IMPORTANT]  
> Start with these two articles in the GitHub Actions documentation: [Reusing workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows) and [Avoiding duplication](https://docs.github.com/en/actions/sharing-automations/avoiding-duplication)

## Actions

> [!TIP]
> Composite actions available in this repository.

- [Abort if there is uncommitted code](./.github/actions/ensure-no-uncommitted-code)
- [Add Helm repositories](./.github/actions/add-helm-repositories)
- [Disable man-db triggers](./.github/actions/disable-man-db-triggers)
- [Ensures a branch exists and aborts otherwise](./.github/actions/ensure-branch)
- [Parses the package version](./.github/actions/parse-version)
- [Send Rocket.Chat message](./.github/actions/send-rocket-chat-message)
- [Setup Java](./.github/actions/setup-java)
- [Setup Maven Build Variables](./.github/actions/setup-maven-build-variables)
- [Setup Maven Project Version](./.github/actions/set-maven-project-version)
- [Setup Nexus NPM Repository Access](./.github/actions/setup-npm-nexus-access)
- [Setup Node.JS and NPM dependencies](./.github/actions/setup-node-and-dependencies)
- [Validate Version](./.github/actions/validate-version)

## Workflows

> [!TIP]
> Reusable workflows available in this repository.

- [Archetype Update](./.github/workflows/update-archetype.yml)
- [Changelog Update](./.github/workflows/changelog-update.yml)
- [Deploy DEV](./.github/workflows/deploy-dev.yml)
- [Docker Images Move](./.github/workflows/docker-images-move.yml)
- [Git Patch Branch Create](./.github/workflows/git-parch-branch-create.yml)
- [Git Tag Create](./.github/workflows/git-tag.yml)
- [Jira Release](./.github/workflows/jira-release.yml)
- [NPM Lint](./.github/workflows/npm-lint.yml)
- [Nexus Artifacts Move](./.github/workflows/move-nexus-artifacts.yml)
- [Nexus Tag Associate](./.github/workflows/nexus-tag-associate.yml)
- [Nexus Tag Create](./.github/workflows/nexus-tag-create.yml)
- [Nexus Tag Search](./.github/workflows/nexus-tag-search.yml)
- [Setup Maven Build Variables](./.github/workflows/setup-maven-build-variables.yml)
- [Tag Nexus Artifacts](./.github/workflows/nexus-tag-search.yml)
- [Version Bump](./.github/workflows/version-bump.yml)

## Workflows vs. Actions

| Reusable workflows                                                                           | Composite actions                                                                                                            |
| :------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------- |
| A YAML file, very similar to any standard workflow file                                      | An action containing a bundle of workflow steps                                                                              |
| Each reusable workflow is a single file in the `.github/workflows` directory of a repository | Each composite action is a separate repository, or a directory, containing an `action.yml` file and, optionally, other files |
| Called by referencing a specific YAML file                                                   | Called by referencing a repository or directory in which the action is defined                                               |
| Called directly within a job, not from a step                                                | Run as a step within a job                                                                                                   |
| Can contain multiple jobs                                                                    | Does not contain jobs                                                                                                        |
| Each step is logged in real-time                                                             | Logged as one step even if it contains multiple steps                                                                        |
| Can connect a maximum of four levels of workflows                                            | Can be nested to have up to 10 composite actions in one workflow                                                             |
| Can use secrets                                                                              | Cannot use secrets                                                                                                           |

## Development

### Local Testing

Some workflows can be run locally using [act](https://github.com/nektos/act).

Examples:

    act -W '.github/workflows/test-validate-version.yml' --input version=9.5.0-202504281107-91-fc989f5 --container-architecture linux/amd64

    act -j build -W '.github/workflows/test-maven.yml' --secret NEXUS3_PW=test --var NEXUS3_USER=test --container-architecture linux/amd64
