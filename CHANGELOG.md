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
- Added `dependabot-pr.yml`: validates Dependabot PRs before merge, since the main workflow skips `dependabot/**` branches. Runs read-only and secret-free: classifies the update via `dependabot/fetch-metadata`, runs `actionlint`, fails when a PR adds an external action not pinned to a commit SHA, and runs the Prettier tooling check for npm updates. Also pins the remaining third-party actions to commit SHAs and adds `.github/actionlint.yaml` declaring the self-hosted `macduff` label ([GH-57](https://github.com/uniport/workflows/pull/57))
- Extracted the SBOM generation, attestation and Dependency-Track upload from `shared-build-pipeline.yml` into a standalone reusable workflow `shared-sbom.yml`. The shared build pipeline now calls it (no behaviour change); pipelines that do not use the shared build pipeline (e.g. `uniport-gateway`) can reuse the exact same supply-chain steps by calling `shared-sbom.yml` with the build version. The Dependency-Track upload can be disabled with `upload_to_dependency_track: false` for repositories that cannot use a self-hosted internal-network runner (e.g. public repositories); SBOM generation and attestation still run

### Fixed

- `release-docker-images` now also copies cosign attestation and signature tags (`sha256-<digest>.att`/`.sig`) when promoting Docker images from staging to release, so released images stay verifiable after staging cleanup; image copies now run sequentially and properly fail the job on errors
- `copy-docker-images` now also copies the cosign attestation and signature tags (`sha256-<digest>.att`/`.sig`) alongside the image, so images mirrored to another registry (e.g. the public GitHub Container Registry) stay verifiable with `cosign verify-attestation`
- `shared-maven-build.yml` now checks out the PR head under `pull_request_target` so Dependabot PR builds verify the proposed changes instead of the base branch
- `publish-spotbugs-report` and `publish-checkstyle-report` now publish the report before failing on violations, and no longer add a confusing secondary failure when the analysis cannot run because an earlier build step failed (e.g. unresolvable dependencies) ([GH-50](https://github.com/uniport/workflows/pull/50))

[unreleased]: https://github.com/uniport/workflows/compare/73134d30c856eaabc9c891492f265b896517382c...main
