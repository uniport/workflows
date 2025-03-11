# Uniport Workflows

A collection of reusable workflows and composite actions to avoid duplicating the content of workflows in GitHub actions.

> [!IMPORTANT]  
> Start with these two articles in the GitHub Actions documentation: [Reusing workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows) and [Avoiding duplication](https://docs.github.com/en/actions/sharing-automations/avoiding-duplication)

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
