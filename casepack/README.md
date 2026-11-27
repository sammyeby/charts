# CasePack Helm Chart

Umbrella Helm chart that deploys the full CasePack stack — API, SPA, PostgreSQL, Keycloak, Gotenberg, and SeaweedFS — in a single command.

## Quick Start

```bash
helm repo add sammyeby https://sammyeby.github.io/charts/
helm repo update

helm upgrade --install casepack sammyeby/casepack \
  --namespace casepack \
  --create-namespace
```

This installs CasePack with all bundled infrastructure using default dev credentials. **Not suitable for production without overrides.**

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   CasePack Umbrella Chart                    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ casepack-api │  │ casepack-spa │  │    postgresql     │  │
│  │  (subchart)  │  │  (subchart)  │  │    (subchart)     │  │
│  └──────┬───────┘  └──────────────┘  └────────┬─────────┘  │
│         │                                      │            │
│         ├──── OIDC auth ──┐                    │            │
│         ├──── JDBC ───────┼────────────────────┘            │
│         ├──── HTML → PDF ─┐                                 │
│         │                 │                                 │
│  ┌──────┴───────┐         │                                 │
│  │  gotenberg   │◀────────┘                                 │
│  │  (subchart)  │                                           │
│         │                 │                                 │
│  ┌──────┴───────┐  ┌─────┴──────┐                          │
│  │  seaweedfs   │  │  keycloak  │                          │
│  │  (subchart)  │  │ (subchart) │                          │
│  └──────────────┘  └────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Subcharts

| Component | Chart | Version | Condition |
|---|---|---|---|
| CasePack API | `casepack-api` | `0.37.0` | Always enabled |
| CasePack SPA | `casepack-spa` | `0.36.0` | Always enabled |
| PostgreSQL | `postgresql` (SamSoft) | `2.3.2` | `postgresql.enabled` |
| Keycloak | `keycloak` (SamSoft) | `1.4.1` | `keycloak.enabled` |
| Gotenberg | `gotenberg` (SamSoft) | `0.2.0` | `gotenberg.enabled` |
| SeaweedFS | `seaweedfs` | `4.34.0` | `seaweedfs.enabled` |

## Self-Host License Setup

Run `./activate.sh <activation-token>` first. It writes `license.jwt`, `activation.json`,
and the self-host values in `.env`.

For Kubernetes, provide self-host runtime values through a Kubernetes Secret
referenced by `casepack-api.secrets.existingSecret`. Create the env file outside
git:

```bash
cat > /tmp/casepack-api-selfhost.env <<'EOF'
DB_URL=jdbc:postgresql://casepack-postgresql-primary:5432/casepack
DB_USER=casepack
DB_PASS=change-me
S3_ACCESS_KEY=admin
S3_SECRET_KEY=admin123456
S3_PUBLIC_ENDPOINT=https://s3.casepack.example.com
CASEPACK_LICENSE_TOKEN=<contents-of-license.jwt>
CASEPACK_LICENSE_KEY_SOURCE=jwks
CASEPACK_LICENSE_JWKS_URL=https://licensing.samuelumeh.com/.well-known/jwks.json
CASEPACK_DEPLOYMENT_MODE=self_host
CASEPACK_INSTALLATION_ID=inst_your-installation-id
CASEPACK_SELF_HOST_BOOTSTRAP_ENABLED=true
CASEPACK_SELF_HOST_BOOTSTRAP_TENANT_NAME=CasePack Workspace
CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_EMAIL=owner@example.com
CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_INITIAL_PASSWORD=change-me-on-first-login
CASEPACK_KEYCLOAK_BASE_URL=http://casepack-keycloak
CASEPACK_KEYCLOAK_REALM=casepack
CASEPACK_KEYCLOAK_SPA_CLIENT_ID=casepack-spa
CASEPACK_KEYCLOAK_SPA_REDIRECT_URI=http://localhost:3000/auth/callback
CASEPACK_KEYCLOAK_SA_CLIENT_ID=casepack-user-manager
CASEPACK_KEYCLOAK_SA_CLIENT_SECRET=casepack-user-manager-secret
EOF

kubectl create secret generic casepack-api-selfhost \
  --namespace casepack \
  --from-env-file=/tmp/casepack-api-selfhost.env
```

Then install with:

```yaml
casepack-api:
  secrets:
    existingSecret: "casepack-api-selfhost"

keycloak:
  bootstrapRealm:
    existingSecret: "casepack-api-selfhost"
```

The Docker Compose path mounts `license.jwt` and `activation.json` directly. For
Kubernetes, keep those files outside git and project the required values into
the API Secret.

### Renewal

For Kubernetes, run `./renew-license.sh --no-restart`, update the license secret, then restart the API deployment:

```bash
kubectl create secret generic casepack-api-selfhost \
  --namespace casepack \
  --from-env-file=/tmp/casepack-api-selfhost.env \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout restart deployment/casepack-casepack-api -n casepack
```

## Keycloak Realm, Theme, and Email

When bundled Keycloak is enabled, the chart installs the official CasePack
theme and imports the `casepack` realm during Keycloak's first startup. The
realm includes the SPA and user-management clients needed for onboarding.
The theme image is published publicly on GHCR, so no registry pull Secret is
required. If your cluster pulls images through a private mirror or registry
that requires authentication, create a pull Secret in the release namespace
and add it to `keycloak.imagePullSecrets`.

For a multi-user deployment, configure Keycloak SMTP so CasePack can send
invitations, password-setup links, and password-reset emails. Create a Secret
in the release namespace before installing the chart:

```bash
kubectl create secret generic casepack-keycloak-smtp \
  --namespace casepack \
  --from-literal=KC_SMTP_HOST=smtp.example.com \
  --from-literal=KC_SMTP_PORT=587 \
  --from-literal=KC_SMTP_FROM=noreply@example.com \
  --from-literal=KC_SMTP_FROM_DISPLAY_NAME=CasePack \
  --from-literal=KC_SMTP_AUTH=true \
  --from-literal=KC_SMTP_USER=your-smtp-username \
  --from-literal=KC_SMTP_PASSWORD=your-smtp-password \
  --from-literal=KC_SMTP_STARTTLS=true \
  --from-literal=KC_SMTP_SSL=false
```

Reference it from your values file:

```yaml
keycloak:
  smtp:
    existingSecret: casepack-keycloak-smtp
```

Port `587` with STARTTLS is common. For implicit TLS on port `465`, set
`KC_SMTP_PORT=465`, `KC_SMTP_STARTTLS=false`, and `KC_SMTP_SSL=true`. For an
unauthenticated private relay, set `KC_SMTP_AUTH=false` and leave
`KC_SMTP_USER` and `KC_SMTP_PASSWORD` empty. Do not enable STARTTLS and SSL at
the same time.

Keycloak only imports a realm when it does not already exist. For an existing
installation, configure email under **Realm settings → Email** in the
`casepack` realm and use **Test connection**. If needed, select `casepack` as
both the login theme and email theme under **Realm settings → Themes**.

## Production Deployment

Disable bundled infrastructure and point to managed services:

```yaml
# production-values.yaml
postgresql:
  enabled: false

keycloak:
  enabled: false

gotenberg:
  enabled: false

seaweedfs:
  enabled: false

casepack-api:
  secrets:
    existingSecret: "casepack-api-secrets"
  config:
    oidcIssuerUri: "https://auth.example.com/realms/casepack"
    s3Endpoint: "http://object-store.internal:8333"
    s3PublicEndpoint: "https://s3.casepack.example.com"
    s3Region: "eu-central-1"
    s3PathStyle: "true"
    gotenbergUrl: "http://gotenberg.gotenberg-prod.svc.cluster.local:3000"
    corsOrigins: "https://casepack.example.com"
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: api.casepack.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: casepack-api-tls
        hosts:
          - api.casepack.example.com
```

```bash
helm upgrade --install casepack sammyeby/casepack \
  --namespace casepack \
  --create-namespace \
  -f production-values.yaml
```

## Parameters

### Global

| Parameter | Description | Default |
|---|---|---|
| `global.domain` | Base domain for subcharts | `casepack.example.com` |
| `global.storageClass` | StorageClass for all PVCs | `""` (cluster default) |

### CasePack API (`casepack-api.*`)

| Parameter | Description | Default |
|---|---|---|
| `casepack-api.replicaCount` | Number of API replicas | `1` |
| `casepack-api.image.repository` | API image repository | `ghcr.io/sammyeby/casepack-api` |
| `casepack-api.image.tag` | API image tag | `""` (chart appVersion) |
| `casepack-api.config.oidcIssuerUri` | OIDC issuer URI | `http://casepack-keycloak/realms/casepack` |
| `casepack-api.config.s3Endpoint` | Internal S3 endpoint used by API server-side storage operations | `http://casepack-seaweedfs-s3:8333` |
| `casepack-api.config.s3PublicEndpoint` | Optional browser-facing S3 endpoint for presigned URLs; include `S3_PUBLIC_ENDPOINT` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.config.gotenbergUrl` | Internal Gotenberg service URL used for document conversion | `http://casepack-gotenberg:3000` |
| `casepack-api.config.corsOrigins` | CORS allowed origins | `http://localhost:3000` |
| `casepack-api.config.deploymentMode` | Deployment mode; include `CASEPACK_DEPLOYMENT_MODE` in `existingSecret` when using the Secret path | `self_host` |
| `casepack-api.config.installationId` | Installation ID; include `CASEPACK_INSTALLATION_ID` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.config.licenseKeySource` | License key source | `jwks` |
| `casepack-api.config.licenseJwksUrl` | Licensing JWKS URL | `https://licensing.samuelumeh.com/.well-known/jwks.json` |
| `casepack-api.config.activationFile` | Activation bundle path when mounted as a file | `/run/secrets/activation.json` |
| `casepack-api.config.selfHostBootstrapEnabled` | Bootstrap toggle; include `CASEPACK_SELF_HOST_BOOTSTRAP_ENABLED` in `existingSecret` when using the Secret path | `true` |
| `casepack-api.config.selfHostBootstrapTenantName` | Initial tenant name; include `CASEPACK_SELF_HOST_BOOTSTRAP_TENANT_NAME` in `existingSecret` when using the Secret path | `CasePack Workspace` |
| `casepack-api.config.selfHostBootstrapAdminEmail` | Bootstrap admin email; include `CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_EMAIL` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.config.selfHostBootstrapAdminInitialPassword` | Bootstrap admin initial password; include `CASEPACK_SELF_HOST_BOOTSTRAP_ADMIN_INITIAL_PASSWORD` in `existingSecret` when using the Secret path | `""` |
| `casepack-api.secrets.existingSecret` | Use pre-created K8s Secret | `""` |
| `casepack-api.secrets.dbUrl` | PostgreSQL JDBC URL | `jdbc:postgresql://casepack-postgresql-primary:5432/casepack` |
| `casepack-api.secrets.dbPass` | Database password | `casepack` |
| `casepack-api.secrets.licenseToken` | Inline license JWT as `CASEPACK_LICENSE_TOKEN` | `""` |
| `casepack-api.secrets.licenseTokenFile` | Helper value for rendering a wrapper-owned `license.jwt` Secret | `""` |
| `casepack-api.secrets.activationBundle` | Helper value for rendering a wrapper-owned `activation.json` Secret | `""` |
| `casepack-api.ingress.enabled` | Enable API Ingress | `false` |

### CasePack SPA (`casepack-spa.*`)

| Parameter | Description | Default |
|---|---|---|
| `casepack-spa.enabled` | Deploy bundled SPA | `true` |
| `casepack-spa.replicaCount` | Number of SPA replicas | `1` |
| `casepack-spa.image.repository` | SPA image repository | `ghcr.io/sammyeby/casepack-spa` |
| `casepack-spa.config.apiBaseUrl` | API base URL | `http://localhost:8080` |
| `casepack-spa.config.oidcAuthority` | OIDC authority URL | `http://localhost:8081/realms/casepack` |
| `casepack-spa.config.deploymentMode` | SPA deployment mode | `SELF_HOST` |
| `casepack-spa.config.licensingPortalUrl` | Licensing portal URL | `https://licensing.samuelumeh.com/portal` |
| `casepack-spa.ingress.enabled` | Enable SPA Ingress | `false` |

### PostgreSQL (`postgresql.*`)

| Parameter | Description | Default |
|---|---|---|
| `postgresql.enabled` | Deploy bundled PostgreSQL | `true` |
| `postgresql.auth.database` | Database name | `casepack` |
| `postgresql.auth.username` | Database user | `casepack` |
| `postgresql.auth.password` | Database password | `casepack` |
| `postgresql.auth.postgresPassword` | Superuser password | `postgres` |
| `postgresql.primary.persistence.size` | PVC size | `10Gi` |

### Keycloak (`keycloak.*`)

| Parameter | Description | Default |
|---|---|---|
| `keycloak.enabled` | Deploy bundled Keycloak | `true` |
| `keycloak.auth.adminUser` | Admin username | `admin` |
| `keycloak.auth.adminPassword` | Admin password | `admin` |
| `keycloak.imagePullSecrets` | Optional registry pull Secrets for Keycloak and the theme loader; the theme image is public, so none are required by default | `[]` |
| `keycloak.externalDatabase.host` | Database host | `casepack-postgresql-primary` |
| `keycloak.externalDatabase.database` | Database name | `keycloak` |
| `keycloak.externalDatabase.user` | Database user | `keycloak` |
| `keycloak.externalDatabase.password` | Database password | `keycloak` |
| `keycloak.bootstrapRealm.existingSecret` | Existing Secret containing `CASEPACK_KEYCLOAK_SA_CLIENT_SECRET`; use the API Secret when applicable | `""` |
| `keycloak.smtp.existingSecret` | Existing Secret containing all nine `KC_SMTP_*` keys | `""` |
| `keycloak.smtp.host` | SMTP server used when the chart creates the Secret | `""` |
| `keycloak.smtp.port` | SMTP port | `587` |
| `keycloak.smtp.from` | Sender email address; replace for multi-user deployments | `noreply@localhost` |
| `keycloak.smtp.fromDisplayName` | Sender display name | `CasePack` |
| `keycloak.smtp.auth` | Enable SMTP authentication | `true` |
| `keycloak.smtp.user` | SMTP username | `""` |
| `keycloak.smtp.password` | SMTP password; prefer `existingSecret` in production | `""` |
| `keycloak.smtp.starttls` | Enable STARTTLS | `true` |
| `keycloak.smtp.ssl` | Enable implicit TLS | `false` |
| `keycloak.theme.image.repository` | Official CasePack theme image repository | `ghcr.io/sammyeby/keycloak-themes` |
| `keycloak.theme.image.tag` | Official CasePack theme image tag | `0.5.0` |
| `keycloak.theme.image.pullPolicy` | Theme loader image pull policy | `IfNotPresent` |
| `keycloak.ingress.enabled` | Enable Keycloak Ingress | `false` |

### Gotenberg (`gotenberg.*`)

| Parameter | Description | Default |
|---|---|---|
| `gotenberg.enabled` | Deploy bundled internal Gotenberg renderer | `true` |
| `gotenberg.service.type` | Gotenberg service type | `ClusterIP` |
| `gotenberg.networkPolicy.enabled` | Create Gotenberg NetworkPolicy | `true` |
| `gotenberg.networkPolicy.allowExternal` | Allow any pod to call Gotenberg | `false` |
| `gotenberg.networkPolicy.allowExternalEgress` | Allow unrestricted Gotenberg egress | `false` |
| `gotenberg.networkPolicy.clientLabels` | Required same-namespace client labels | `{gotenberg-client: "true"}` |

### SeaweedFS (`seaweedfs.*`)

| Parameter | Description | Default |
|---|---|---|
| `seaweedfs.enabled` | Deploy bundled SeaweedFS | `true` |
| `seaweedfs.image.repository` | Image repository | `chrislusf/seaweedfs` |
| `seaweedfs.image.tag` | Image tag | `latest` |
| `seaweedfs.s3.port` | S3 gateway port | `8333` |
| `seaweedfs.persistence.size` | PVC size | `10Gi` |

## Keycloak Database Init

When both `postgresql.enabled` and `keycloak.enabled` are `true`, the chart deploys a `post-install` Job that creates the `keycloak` database and user in the bundled PostgreSQL instance.

## Upgrading

### To 0.8.6

Synchronize `Chart.lock` with the dependencies already declared in 0.8.5:
CasePack API `0.35.1` and SPA `0.35.0`. This restores reproducible dependency
builds from a source checkout. Values and application image defaults are
unchanged; no migration action is required.

### To 0.8.3

- **Licensing host**: the default licensing JWKS URL, base URL and portal link move from `licensing.bysam.io` to `licensing.samuelumeh.com`, where SamSoft now runs licensing. The old host keeps serving for now, so existing installs keep working; the defaults change only for installs that don't set these values.
- **Action**: none, unless you set `casepack-api.config.licenseJwksUrl`, `casepack-api.config.licensingBaseUrl` or `casepack-spa.config.licensingPortalUrl` to a `licensing.bysam.io` URL; then point them at `licensing.samuelumeh.com`.

### To 0.8.0

- **Subcharts brought up to date**: 0.7.1 was published with `casepack-api` and `casepack-spa` 0.32.0. Their later pin updates came without a chart version bump, so they were never published. 0.8.0 carries `casepack-api` and `casepack-spa` 0.34.0, `keycloak` 1.4.1 and `postgresql` 2.3.2. It is a minor release because it includes two CasePack releases. The Keycloak image tag stays `26.7.4-optimized`; its repository is now set in this chart as `keycloak.image.repository: sammyeby/keycloak`.
- **Registry move**: the CasePack API, SPA, Keycloak and theme images, the Keycloak database init image and every subchart except SeaweedFS now come from `ghcr.io/sammyeby`, where SamSoft now publishes them. Every existing version was copied there with an identical digest, so the same image runs. `ghcr.io/bysamio` keeps the versions it has but gets no new ones.
- **Action**: if you override `casepack-api.image.repository`, `casepack-spa.image.repository`, `keycloak.image.repository` or `keycloak.theme.image.repository`, point them at `sammyeby` to keep receiving updates. `keycloak.image.repository` is a new default here; no values were renamed or removed.

### To 0.7.1

Security update: the bundled Keycloak now runs image `26.7.4-optimized` (was
`26.7.3-optimized`). It picks up six upstream Keycloak CVE fixes and a Bouncy
Castle overlay for `CVE-2026-8763` (CRITICAL). See the
[Keycloak chart upgrade notes](../keycloak/README.md#to-141) for details. No
values changed. If you override `keycloak.image.tag`, move it to `26.7.4-optimized`.

### To 0.6.0

This release adds the CasePack Keycloak theme, first-start realm import, and
Secret-backed Keycloak SMTP settings. New installations receive the bootstrap
realm automatically. Keycloak skips startup imports for an existing realm, so
existing installations should configure SMTP and select the `casepack` themes
in the Keycloak Admin Console as described above.

```bash
helm upgrade casepack sammyeby/casepack \
  --namespace casepack \
  -f your-values.yaml
```

## Uninstall

```bash
helm uninstall casepack --namespace casepack
```

> **Note:** PVCs for PostgreSQL and SeaweedFS are retained after uninstall. Delete them manually if you want a clean slate:
> ```bash
> kubectl delete pvc -l app.kubernetes.io/instance=casepack -n casepack
> ```

## Standalone Charts

| Chart | Helm Repo |
|---|---|
| CasePack API | `sammyeby/casepack-api` |
| CasePack SPA | `sammyeby/casepack-spa` |
| Keycloak | `sammyeby/keycloak` |
| Gotenberg | `sammyeby/gotenberg` |
| SeaweedFS | `seaweedfs/seaweedfs` |
| PostgreSQL | `sammyeby/postgresql` |

## Support

- [CasePack Deployment Guide](https://github.com/sammyeby/casepack)
- [SamSoft Charts](https://github.com/sammyeby/charts)
