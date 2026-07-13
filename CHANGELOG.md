# Changelog

All notable changes to this project will be documented in this file. The changes should be categorized under one of
these sections: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed` or `Security`.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added workflows and actions for running the release pipeline with github actions ([PORTAL-1673](https://inventage-all.atlassian.net/browse/PORTAL-1673))

### Fixed

- `shared-maven-build.yml` now checks out the PR head under `pull_request_target` so Dependabot PR builds verify the proposed changes instead of the base branch
- `publish-spotbugs-report` and `publish-checkstyle-report` now publish the report before failing on violations, and no longer add a confusing secondary failure when the analysis cannot run because an earlier build step failed (e.g. unresolvable dependencies) ([GH-50](https://github.com/uniport/workflows/pull/50))

[unreleased]: https://github.com/uniport/workflows/compare/73134d30c856eaabc9c891492f265b896517382c...main
