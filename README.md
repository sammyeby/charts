# SamSoft Helm Charts

Helm charts for CasePack and Kubernetes infrastructure, maintained by **SamSoft Technologies**, a small business based in Germany.

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/sammyeby)](https://artifacthub.io/packages/search?repo=sammyeby)

## Quick Start

### OCI Registry (Helm 3.8+)

Install charts directly from GitHub Container Registry:

```bash
helm install casepack oci://ghcr.io/sammyeby/charts/casepack
helm install my-wordpress oci://ghcr.io/sammyeby/charts/wordpress
helm install my-keycloak oci://ghcr.io/sammyeby/charts/keycloak
```

These commands select the latest published chart. Use `--version` to pin a chart
version from the table below. Chart versions and container image tags are
separate: for example, WordPress chart `3.0.1` defaults to image `7.1.3`.
Consult the chart README for required credentials and deployment configuration;
CasePack also requires a license and configured identity/storage services.

### Traditional Helm Repository

```bash
helm repo add sammyeby https://sammyeby.github.io/charts/
helm repo update
helm install my-wordpress sammyeby/wordpress
```

## Available Charts and Default Images

These versions describe this source checkout. Chart versions come from each
`Chart.yaml`; default images come from `values.yaml` and the image templates.
The CasePack API, SPA and docs charts use `appVersion` when `image.tag` is empty.

| Chart / documentation | Chart version | Default application image |
|-----------------------|---------------|---------------------------|
| [casepack](./casepack/README.md) | `0.8.5` | Umbrella chart; see its pinned dependencies |
| [casepack-api](./casepack-api/README.md) | `0.35.1` | `ghcr.io/sammyeby/casepack-api:0.35.1` |
| [casepack-spa](./casepack-spa/README.md) | `0.35.0` | `ghcr.io/sammyeby/casepack-spa:0.35.0` |
| [casepack-docs](./casepack-docs/Chart.yaml) | `0.12.0` | `ghcr.io/sammyeby/casepack-docs:0.12.0` |
| [wordpress](./wordpress/README.md) | `3.0.1` | `ghcr.io/sammyeby/wordpress:7.1.3` |
| [keycloak](./keycloak/README.md) | `1.4.2` | `ghcr.io/sammyeby/keycloak:26.7.4` |
| [postgresql](./postgresql/README.md) | `2.3.2` | `ghcr.io/sammyeby/postgresql:17.10-alpine` |
| [mariadb](./mariadb/README.md) | `1.0.3` | `docker.io/mariadb:12.0.2` |
| [memcached](./memcached/README.md) | `1.0.3` | `docker.io/memcached:1.6.24-alpine` |
| [minio](./minio/README.md) | `1.0.4` | `quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z` |
| [gotenberg](./gotenberg/README.md) | `0.2.1` | `gotenberg/gotenberg:8-chromium` |

The published catalog is available on the [Helm repository landing page](https://sammyeby.github.io/charts/)
and [Artifact Hub](https://artifacthub.io/packages/search?repo=sammyeby).
An image available in [sammyeby/images](https://github.com/sammyeby/images) does
not change chart defaults until the corresponding chart update is released.

WordPress, Keycloak and PostgreSQL use SamSoft hardened images based on upstream
projects. MariaDB, Memcached, MinIO and Gotenberg use upstream images. WordPress
runs as UID/GID 1001 on port 8080. Keycloak defaults to the flexible variant at
UID/GID 1001; the optional `-optimized` and `-debug` variants use UID/GID 65532.

The CasePack umbrella pins subchart versions in [casepack/Chart.yaml](./casepack/Chart.yaml),
which can differ from standalone chart versions above. WordPress and Keycloak
also pin their dependencies in their own `Chart.yaml` files. Check those pins
and umbrella overrides when determining the images in a complete deployment.

## Usage

### Install WordPress with MariaDB

```bash
helm install my-wordpress oci://ghcr.io/sammyeby/charts/wordpress \
  --set mariadb.auth.rootPassword=example-root-password \
  --set mariadb.auth.password=example-database-password \
  --set wordpressPassword=example-admin-password
```

Replace example passwords before use. See the [WordPress chart documentation](./wordpress/README.md)
for existing Secret support and configuration details.

### Custom Values Example

This example uses the chart's hardened WordPress image and its matching UID/port
defaults. Save it as `values.yaml`:

```yaml
image:
  registry: ghcr.io
  repository: sammyeby/wordpress
  tag: "7.1.3"

wordpressUsername: admin
wordpressEmail: admin@example.com
wordpressBlogName: "My WordPress Site"
wordpressPassword: example-admin-password

mariadb:
  enabled: true
  auth:
    rootPassword: example-root-password
    database: wordpress
    username: wpuser
    password: example-database-password

service:
  type: LoadBalancer

persistence:
  enabled: true
  size: 20Gi
```

```bash
helm install my-wp sammyeby/wordpress -f values.yaml
```

### Migration

SamSoft charts and custom images are published under `ghcr.io/sammyeby`.
For existing releases, review each chart's upgrade notes and update explicit
image/chart repository overrides that still point to `ghcr.io/bysamio`.
Verify that the selected tag or digest exists at the destination before upgrading.
The WordPress runtime user is still named `bysamio` for compatibility.

When migrating from Bitnami, review values, secrets, environment variables,
volume ownership and backup/restore procedures for each chart. The WordPress
chart defaults to SamSoft's UID/GID 1001 image on port 8080. Switching to
`docker.io/wordpress` also requires matching ports and security contexts; an
image repository substitution alone is insufficient. Charts can include init
containers and setup jobs; inspect the rendered manifests before deployment.

## Automation

Application release workflows in `casepack-api` and `casepack-spa` open immediate chart update PRs in this repository after stable image releases. Renovate remains enabled here as a chart-owned safety net and for infrastructure image updates.

After the OCI chart release job succeeds, this repository notifies `sammyeby/argocd` for the CasePack API, SPA, and docs chart versions. Its automation opens or updates a staging PR only for a newer published chart. The CasePack Keycloak values revision moves with the API release. A production PR follows after the exact staging revisions are Synced, Healthy, and pass a public smoke check. The notification needs the GitHub App variable and secret documented in `argocd/docs/release-promotion.md`; publication still succeeds with a warning until those credentials are configured.

| Chart | Image | Renovate behavior |
|-------|-------|-------------------|
| `casepack-api` | `ghcr.io/sammyeby/casepack-api` | Sync chart `version` and `appVersion` to stable app image tags |
| `casepack-spa` | `ghcr.io/sammyeby/casepack-spa` | Sync chart `version` and `appVersion` to stable app image tags |
| `casepack-docs` | `ghcr.io/sammyeby/casepack-docs` | Sync chart `version` and `appVersion` to stable docs image tags |
| `keycloak` | `ghcr.io/sammyeby/keycloak` | Update image tag, sync `appVersion`, bump chart major/minor/patch to match image update type |
| `wordpress` | `ghcr.io/sammyeby/wordpress` | Update image tag, sync `appVersion`, bump chart major/minor/patch to match image update type |
| `postgresql` | `ghcr.io/sammyeby/postgresql` | Update image tag, sync `appVersion`, bump chart major/minor/patch to match image update type |

Snapshot, SHA, and `latest` tags are ignored. PostgreSQL tracking is limited to `*-alpine` image tags.

## Development

Chart source lives in `<chart>/Chart.yaml`, `<chart>/values.yaml` and
`<chart>/templates/`. Each chart has its own README with configuration and
upgrade guidance.

```bash
cd wordpress
helm dependency build
helm lint . -f ../test-minikube-values.yaml
helm template my-test . -f ../test-minikube-values.yaml
```

`helm dependency build` uses `Chart.lock` when present; use `helm dependency update`
when intentionally updating dependency resolution. See [scripts/README.md](./scripts/README.md)
for the repository's pre-commit checks.

## Maintainer and Support

**SamSoft Technologies** — [@sammyeby](https://github.com/sammyeby)

- [GitHub repository](https://github.com/sammyeby/charts)
- [Issues and support](https://github.com/sammyeby/charts/issues)
- [Container images](https://github.com/sammyeby/images)

Contributions are welcome through pull requests. See individual charts and their
upstream projects for applicable license terms.
