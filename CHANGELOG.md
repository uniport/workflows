# Changelog

All notable changes to this project will be documented in this file. The changes should be categorized under one of
these sections: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed` or `Security`.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added workflows and actions for running the release pipeline with github actions ([PORTAL-1673](https://inventage-all.atlassian.net/browse/PORTAL-1673))

### Fixed

- The release `announce` job is no longer skipped when optional upstream jobs (promote, git-tag, jira-release, archetype) are skipped; its condition now uses `always()` and only suppresses the announcement on failure or cancellation.
- The release workflow run summary now renders the parsed version metadata correctly (it previously referenced non-existent uppercase `parse` outputs and rendered blank).

### Security

- Hardened all reusable workflows and composite actions against shell script injection: every `github.*`, `inputs.*`, `secrets.*`, and `vars.*` value interpolated into a `run:` step is now passed via `env:` and referenced as a quoted shell variable. Removed the `eval` in the Add Helm Repositories action (now a bash argument array) and moved Nexus, macOS keychain, skopeo, and Jira credentials off command lines. Removed the step that printed the generated `.npmrc` auth token to the build log.

[unreleased]: https://github.com/uniport/workflows/compare/73134d30c856eaabc9c891492f265b896517382c...main
