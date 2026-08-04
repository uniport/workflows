#!/usr/bin/env zx
/* global $, argv, chalk */

// Be quiet by default
$.verbose = argv.verbose || false;

const NEXUS_USER = process.env.NEXUS_USER;
const NEXUS_PW = process.env.NEXUS_PW;
const [NEXUS_TAG] = argv._;
const NEXUS3_URL = process.env.NEXUS3_URL || 'https://nexus3.inventage.com';
const DOCKER_STAGING_REGISTRY = process.env.DOCKER_STAGING_REGISTRY || 'uniportcr.artifacts.inventage.com';
const DOCKER_RELEASE_REGISTRY = process.env.DOCKER_RELEASE_REGISTRY || 'docker-registry.inventage.com:10093';

if (!NEXUS_USER || !NEXUS_PW) {
  console.error(`${chalk.bold('NEXUS_USER')} and ${chalk.bold('NEXUS_PW')} have to be set.`);
  process.exit(1);
}

if (!NEXUS_TAG) {
  console.error('No tag was given, not doing anything…');
  process.exit(1);
}

let components = [];

// @see https://nexus3.inventage.com/swagger-ui/
try {
  const nexusRequestUrl = `${NEXUS3_URL}/service/rest/v1/search?tag=${NEXUS_TAG}`;
  const componentsResponse = await fetch(nexusRequestUrl, {
    headers: {
      Authorization: `Basic ${Buffer.from(`${NEXUS_USER}:${NEXUS_PW}`).toString('base64')}`,
    },
  });

  if (!componentsResponse.ok) {
    console.error(`HTTP request to ${nexusRequestUrl} failed: ${componentsResponse.status} ${componentsResponse.statusText}`);
    process.exit(1);
  }

  const { items = [] } = await componentsResponse.json();
  components = items.filter(c => c.format === 'docker');
} catch (e) {
  console.error(e);
}

// Bail if no components were found
if (components.length < 1) {
  console.error(`No docker components found associated with tag ${chalk.bold(NEXUS_TAG)}`);
  process.exit(1);
}

for (const c of components) {
  const imageName = `${c.name}:${c.version}`;
  const source = `${DOCKER_STAGING_REGISTRY}/${imageName}`;
  const dest = `${DOCKER_RELEASE_REGISTRY}/${imageName}`;

  console.info(`Moving docker image ${chalk.bold(source)} to ${chalk.bold(dest)}…`);

  // @see https://github.com/containers/skopeo
  await $`skopeo copy -a --src-creds ${NEXUS_USER}:${NEXUS_PW} --dest-creds ${NEXUS_USER}:${NEXUS_PW} docker://${source} docker://${dest}`;

  // Cosign stores SBOM/provenance attestations and signatures as sibling tags of the image
  // (sha256-<digest>.att / .sig). Carry them along so released images stay verifiable after
  // the staging repository gets cleaned up. Images without attestations are copied as before.
  //
  // Non-image artifacts (e.g. Helm charts, whose config media type is
  // application/vnd.cncf.helm.config.v1+json) are never cosign-signed here and don't support the
  // image-specific `skopeo inspect` used below, so skip attestation handling for them. The
  // `skopeo copy -a` above has already moved the artifact itself.
  const rawManifest = JSON.parse((await $`skopeo inspect --raw --creds ${NEXUS_USER}:${NEXUS_PW} docker://${source}`).stdout);
  const configMediaType = rawManifest?.config?.mediaType;
  const imageConfigMediaTypes = ['application/vnd.oci.image.config.v1+json', 'application/vnd.docker.container.image.v1+json'];
  if (configMediaType && !imageConfigMediaTypes.includes(configMediaType)) {
    console.info(`Skipping attestation copy for non-image artifact ${chalk.bold(source)} (config media type ${configMediaType})`);
    continue;
  }

  const digest = (await $`skopeo inspect --format {{.Digest}} --creds ${NEXUS_USER}:${NEXUS_PW} docker://${source}`).stdout.trim();
  for (const suffix of ['att', 'sig']) {
    const attachmentTag = `${digest.replace(':', '-')}.${suffix}`;
    const attachmentSource = `${DOCKER_STAGING_REGISTRY}/${c.name}:${attachmentTag}`;
    const attachmentDest = `${DOCKER_RELEASE_REGISTRY}/${c.name}:${attachmentTag}`;

    try {
      await $`skopeo inspect --raw --creds ${NEXUS_USER}:${NEXUS_PW} docker://${attachmentSource}`;
    } catch {
      continue; // image has no attachment of this kind
    }

    console.info(`Copying ${suffix} attachment ${chalk.bold(attachmentSource)} to ${chalk.bold(attachmentDest)}…`);
    await $`skopeo copy --src-creds ${NEXUS_USER}:${NEXUS_PW} --dest-creds ${NEXUS_USER}:${NEXUS_PW} docker://${attachmentSource} docker://${attachmentDest}`;
  }
}
