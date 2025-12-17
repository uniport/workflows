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

Workflow: Maven-Build
---

Vor Konsolidierung:

| component \ template                   | wie organisation | wie base | weder noch |
|----------------------------------------|:----------------:|:-------:|------------|
| [organisation][organisation-mvn]       |        ✅         |         |            |
| [base][base-mvn]                       |                  |    ✅    |            |
| [conversation][conversation-mvn]       |        ✅         |         |            |
| [notification][notification-mvn]       |        ✅         |        |            |
| [uniport-gateway][uniport-gateway-mvn] |                  |        |      ✅      |
| [dashboard][dashboard-mvn]             |        ✅         |         |            |

[organisation-mvn]: https://github.com/uniport/organisation/blob/master/.github/workflows/maven.yml
[base-mvn]: https://github.com/uniport/base/blob/main/.github/workflows/build.yml
[conversation-mvn]: https://github.com/uniport/conversation/blob/main/.github/workflows/maven.yml
[notification-mvn]: https://github.com/uniport/notification/blob/master/.github/workflows/build.yml
[uniport-gateway-mvn]: https://github.com/uniport/uniport-gateway/blob/main/.github/workflows/build.yml
[dashboard-mvn]: https://github.com/uniport/dashboard/blob/master/.github/workflows/maven.yml