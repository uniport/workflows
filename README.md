# Uniport Workflows

A collection of reusable workflows and composite actions to avoid duplicating the content of workflows in GitHub actions.

> [!IMPORTANT]  
> Start with these two articles in the GitHub Actions documentation: [Reusing workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows) and [Avoiding duplication](https://docs.github.com/en/actions/sharing-automations/avoiding-duplication)

## Actions

> [!TIP]
> Composite actions available in this repository.

- [Add Helm repositories](./.github/actions/add-helm-repositories)
- [Setup Java](./.github/actions/setup-java)
- [Send Rocket.Chat message](./.github/actions/send-rocket-chat-message)
- [Setup Node.JS and NPM dependencies](./.github/actions/setup-node-and-dependencies)
- [Setup Maven Project Version](./.github/actions/set-maven-project-version)
- [Validate Version](./.github/actions/validate-version)

## Workflows

> [!TIP]
> Reusable workflows available in this repository.

- [NPM Lint](./.github/workflows/npm-lint.yml) - Runs NPM the `lint` command defined in `package.json` to ensure code quality and adherence to coding standards.
- [Setup Maven Build Variables](./.github/workflows/setup-maven-build-variables.yml) - Wrapper around the [`setup-maven-build-variables` action](./.github/actions/setup-maven-build-variables) that maps all outputs to the workflow to it can also be used as a reusable workflow as opposed to just a composite action.
- [Deploy DEV](./.github/workflows/deploy-dev.yml) - Workflow for deploying a component version to the DEV environment
- [Update Archetype](./.github/workflows/update-archetype.yml) - Workflow for updating a component version in the Uniport Archetype
- [Nexus Tag Create](./.github/workflows/nexus-tag-create.yml) - Workflow for creating a Nexus tag
- [Nexus Tag Associate](./.github/workflows/nexus-tag-associate.yml) - Workflow for associating components that belong to a Nexus tag
- [Nexus Tag Create](./.github/workflows/nexus-tag-search.yml) - Workflow for searching components that belong to a Nexus tag
- [Nexus Tag Create](./.github/workflows/nexus-tag-search.yml) - Workflow for searching components that belong to a Nexus tag
- [Tag Nexus Artifacts](./.github/workflows/nexus-tag-search.yml) - Workflow for staging (tagging + associating) artifacts of various types (Docker, Helm, Maven, NPM) in Nexus

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
