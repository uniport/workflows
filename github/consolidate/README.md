Build & Release Pipelines
===

https://inventage-all.atlassian.net/wiki/spaces/PORTAL/pages/472907779/GitHub+Actions+Migration

Workflow: Build-Pipeline
---

Vor Konsolidierung:

| component \ template | wie organisation | wie base |
|----------------------|:----------------:|:-------:|
| organisation         |        ✅         |         |
| base                 |                  |    ✅    |
| conversation         |        ✅         |         |
| notification         |                  |    ✅    |
| uniport-gateway      |                  |    ✅    |
| [dashboard]          |        ✅         |         |
| [filestorage]        |        ✅         |         |


Workflow: Maven-Build
---

insert table here ;-)


[dashboard]: https://github.com/uniport/dashboard/blob/master/.github/workflows/build-pipeline.yml
[filestorage]: https://github.com/uniport/filestorage/actions/workflows/build-pipeline.yml