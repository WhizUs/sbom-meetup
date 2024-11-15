# SBOM Example


## Setup

### Traefik
To use HTTP/s, we will need locally trusted development certificates, so we will install [mkcert](https://github.com/FiloSottile/mkcert). Please follow the link to install mkcert for your operating system.

1. create a new local CA if you haven't already.
```
mkcert -install
```

2. create certificates in `apps/traefik/certs` 
```
mkcert -cert-file "local.computer.crt" -key-file "local.computer.key" "local.computer" "*.local.computer"
```

3. apply `traefik` folder with
```
kubectl kustomize apps/traefik --enable-helm | kubectl apply -f -
```

### Dependency Track

Install DependencyTrack with
```
kubectl kustomize apps/dependencytrack --enable-helm | kubectl apply -f -
```

### Build go app & generate SBOMs

```bash
$ make
$ .output/main
```

## DependencyTrack Requests

### publish CycloneDX BOMs

```
curl -X "PUT" "https://dtrack.local.computer/api/v1/bom" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: $(op run --env-file op.env -- printenv DTRACK_API_KEY)" \
     -d "{
      \"projectName\": \"sbom-go\",
      \"projectVersion\": \"v0.0.1\",
      \"bom\":\"$(cat sboms/sbom-go-cyclonedx.grype.json | base64)\"
  }"
```