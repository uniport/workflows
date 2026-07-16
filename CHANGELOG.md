# Changelog

All notable changes to this project will be documented in this file. The changes should be categorized under one of
these sections: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed` or `Security`.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added workflows and actions for running the release pipeline with github actions ([PORTAL-1673](https://inventage-all.atlassian.net/browse/PORTAL-1673))
- Added `shared-dependabot-automerge.yml`: approves and rebase-merges Dependabot PRs after the calling repository's build passed, based on a per-group merge policy (`merge_policy` input; majors, test dependencies and ungrouped/internal dependencies always stay human-reviewed). Merges as the Uniport GitHub App so the regular pipelines on the default branch still trigger; any human commit on a Dependabot branch disarms auto-merge ([GH-51](https://github.com/uniport/workflows/pull/51))
- `shared-build-pipeline.yml` now generates a CycloneDX SBOM (npm frontend sources + syft scan of every pushed Docker image), attests SBOM and SLSA provenance to each image via cosign (key-based, public key published as `cosign.pub`), and uploads the SBOM to Dependency-Track. Runs on the default branch and `X.Y.x` maintenance branches (`sbom_ref_pattern` input, opt out via `generate_sbom: false`); attestation and upload are skipped with a notice when the new optional secrets (`COSIGN_PRIVATE_KEY`, `COSIGN_PASSWORD`, `DEPENDENCY_TRACK_API_KEY`) are absent. New base actions: `nexus-list-docker-images`, `generate-sbom`, `upload-sbom-dependency-track` (see the README section "SBOM, Attestation & Dependency-Track")

### Fixed

- `shared-maven-build.yml` now checks out the PR head under `pull_request_target` so Dependabot PR builds verify the proposed changes instead of the base branch
- `publish-spotbugs-report` and `publish-checkstyle-report` now publish the report before failing on violations, and no longer add a confusing secondary failure when the analysis cannot run because an earlier build step failed (e.g. unresolvable dependencies) ([GH-50](https://github.com/uniport/workflows/pull/50))

[unreleased]: https://github.com/uniport/workflows/compare/73134d30c856eaabc9c891492f265b896517382c...main
