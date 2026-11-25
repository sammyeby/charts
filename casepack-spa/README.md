# CasePack SPA Helm Chart

Deploys the CasePack React SPA (Nginx-served static files) to Kubernetes.

## Installing

```bash
helm install casepack-spa oci://ghcr.io/sammyeby/charts/casepack-spa \
  --namespace casepack --create-namespace \
  -f values-prod.yaml
```

## Configuration

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Docker image repository | `ghcr.io/sammyeby/casepack-spa` |
| `image.tag` | Image tag (defaults to appVersion) | `""` |
| `config.apiBaseUrl` | API base URL injected at runtime | `/api` |
| `config.oidcAuthority` | OIDC issuer URL | `""` |
| `config.oidcClientId` | OIDC client ID | `casepack-spa` |
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `nginx` |
| `ingress.hosts` | Ingress host rules | `[]` |
| `ingress.tls` | TLS configuration | `[]` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `32Mi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `resources.limits.memory` | Memory limit | `64Mi` |
| `nginxConfig` | Complete nginx `default.conf` to use instead of the image's own config (see below) | `""` |

## Runtime Configuration

The Docker entrypoint generates `/usr/share/nginx/html/config.js` from
environment variables at container startup. This allows the same image
to be deployed across environments without rebuilding.

The SPA reads `window.__RUNTIME_CONFIG__` for:
- `API_BASE_URL` — backend API endpoint
- `OIDC_AUTHORITY` — Keycloak realm URL
- `OIDC_CLIENT_ID` — OIDC client identifier

## Nginx Configuration

By default the pod runs the nginx config built into the `casepack-spa` image.
It serves the prerendered marketing pages, falls back to the `noindex` app
shell for app routes and unknown paths, sends the security and cache headers,
and answers `/healthz`.

Setting `nginxConfig` replaces that whole config through a ConfigMap. Only do
this if your config reproduces the same routing and headers.

## Upgrading

### To 0.34.1

`config.licensingPortalUrl` defaults to `https://licensing.samuelumeh.com/portal`, SamSoft's production licensing portal, instead of `https://staging.licensing.bysam.io/portal`. The SPA image is unchanged (0.34.0). Set the value if you point the SPA at another licensing portal.

### To the release after 0.32.0

The chart no longer mounts its own nginx config by default. Earlier versions
always replaced the image's config with a generic SPA fallback
(`try_files $uri $uri/ /index.html`). Since the image started prerendering
the marketing pages, that fallback served the landing page for every app
route and unknown path, and dropped the image's `no-cache` and `noindex`
headers. The security headers and `/healthz` that the chart's config provided
are now part of the image. If you relied on the old ConfigMap, set
`nginxConfig` explicitly. `nginxConfig` was previously ignored; it now takes
effect.
