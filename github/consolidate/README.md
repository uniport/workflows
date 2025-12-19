Build & Release Pipelines
===

https://inventage-all.atlassian.net/wiki/spaces/PORTAL/pages/472907779/GitHub+Actions+Migration

Workflow: Build-Pipeline
---

Vor Konsolidierung:

| component \ template                     | wie organisation | wie base |
|------------------------------------------|:----------------:|:-------:|
| [organisation][organisation-build]       |        ✅         |         |
| [base][base-build]                       |                  |    ✅    |
| [conversation][conversation-build]       |        ✅         |         |
| [notification][notification-build]       |                  |    ✅    |
| [uniport-gateway][uniport-gateway-build] |                  |    ✅    |
| [dashboard][dashboard-build]             |        ✅         |         |

[organisation-build]: https://github.com/uniport/organisation/blob/master/.github/workflows/build-pipeline.yml
[base-build]: https://github.com/uniport/base/blob/main/.github/workflows/main.yml
[conversation-build]: https://github.com/uniport/conversation/blob/main/.github/workflows/build-pipeline.yml
[notification-build]: https://github.com/uniport/notification/blob/master/.github/workflows/main.yml
[uniport-gateway-build]: https://github.com/uniport/uniport-gateway/blob/main/.github/workflows/main.yaml
[dashboard-build]: https://github.com/uniport/dashboard/blob/master/.github/workflows/build-pipeline.yml

Nach Konsolidierung:  
[build-pipeline.yml](../workflows/build-pipeline.yml)

### Findings


Workflow: Maven-Build
---

Vor Konsolidierung:

| component \ template                   | wie organisation | wie base | weder noch | gemerged |
|----------------------------------------|:----------------:|:-------:|------------|----------|
| [organisation][organisation-mvn]       |        ✅         |         |            |          |
| [base][base-mvn]                       |                  |    ✅    |            |      ✅    |
| [conversation][conversation-mvn]       |        ✅         |         |            |     ✅     |
| [notification][notification-mvn]       |        ✅         |        |            |     ✅     |
| [uniport-gateway][uniport-gateway-mvn] |                  |        |      ✅      |          |
| [dashboard][dashboard-mvn]             |        ✅         |         |            |    ✅      |

[organisation-mvn]: https://github.com/uniport/organisation/blob/master/.github/workflows/maven.yml
[base-mvn]: https://github.com/uniport/base/blob/main/.github/workflows/build.yml
[conversation-mvn]: https://github.com/uniport/conversation/blob/main/.github/workflows/maven.yml
[notification-mvn]: https://github.com/uniport/notification/blob/master/.github/workflows/build.yml
[uniport-gateway-mvn]: https://github.com/uniport/uniport-gateway/blob/main/.github/workflows/build.yml
[dashboard-mvn]: https://github.com/uniport/dashboard/blob/master/.github/workflows/maven.yml

### Findings
 - UI Testcoverage only in organisation and base. Useful for other Modules too. Do they have a ui? 
   ```yaml
      - name: Frontend Test Coverage
        uses: livewing/lcov-job-summary@v1.2.0
        with:
          lcov: frontend/src/main/web/coverage/lcov.info
    ```

 ### Notes
 - NEXUS_NPM_TOKEN_WRITE will be optional. Use: 
   ```yaml
    if: ${{ secrets.NEXUS_NPM_TOKEN_WRITE != '' }}
    ```
 - uniport-gateway_main.yaml

   Don't add the docs section to the Common Workflow. To specific. Leave it at the calling workflow.
   ```yaml
   docs:
    name: Deploy Docs (main)
    needs: [build]
    uses: ./.github/workflows/deploy-docs.yml
    # Do not deploy on forks
    if: ${{ !github.repository.fork }}
    permissions:
      actions: read
      statuses: write
      pull-requests: write
      deployments: write
    secrets:
      NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
      NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
    with:
      alias: ${{ needs.build.outputs.branch_name_slug }}
      artifact_name: ${{ needs.build.outputs.docs_artifact_name }}
      artifact_path: ${{ needs.build.outputs.docs_artifact_path }}
      run_id: ${{ needs.build.outputs.run_id }}
      environment: docs
   ```