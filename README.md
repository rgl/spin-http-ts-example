# About

[![Build status](https://github.com/rgl/spin-http-ts-example/workflows/build/badge.svg)](https://github.com/rgl/spin-http-ts-example/actions?query=workflow%3Abuild)

Example Spin HTTP Application written in TypeScript.

# Usage

Install [Node.js](https://github.com/nodejs/node) and [Spin](https://github.com/fermyon/spin).

Install the dependencies:

```bash
npm ci
```

Start the application:

```bash
spin up --build
```

Access the HTTP endpoint:

```bash
xdg-open http://localhost:3000
```

# Container Image Usage

There are two ways to run a WebAssembly binary in a container:

1. Ship the `spin` binary and your `.wasm` file in a container image.
2. Ship your `.wasm` file and the `spin.toml` manifest/metadata file in a
   container image; this can be done in a single step with
   `spin registry push`. Then use a container runtime or orchestrator that
   supports running wasm containers. For example, `containerd` and the
   `spin` containerd shim.

**NB** The Fermyon Cloud directly uses the `.wasm` file, so there is no need to
use a container. Instead use `spin deploy` to deploy the application to the
Fermyon Cloud.

## Kubernetes Usage

See https://developer.fermyon.com/spin/v3/kubernetes.

## containerd Usage

Install [containerd](https://github.com/moby/containerd) and the [containerd-shim-spin](https://github.com/deislabs/containerd-wasm-shims/tree/main/containerd-shim-spin).

### containerd crictl Usage

Use `crictl`:

```bash
# see https://kubernetes.io/docs/concepts/architecture/cri/
# see https://kubernetes.io/docs/tasks/debug/debug-cluster/crictl/
# see https://kubernetes.io/docs/reference/tools/map-crictl-dockercli/
# see https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md
# see https://github.com/kubernetes-sigs/cri-tools/blob/master/cmd/crictl/sandbox.go
# see https://github.com/kubernetes-sigs/cri-tools/blob/master/cmd/crictl/container.go
# see https://github.com/kubernetes/cri-api/blob/kubernetes-1.27.10/pkg/apis/runtime/v1/api.proto
crictl pull \
  ghcr.io/rgl/spin-http-ts-example:0.4.0
crictl images list
crictl info | jq .config.containerd.runtimes
install -d -m 700 /var/log/cri
cat >cri-spin-http-ts-example.pod.yml <<'EOF'
metadata:
  uid: cri-spin-http-ts-example
  name: cri-spin-http-ts-example
  namespace: default
log_directory: /var/log/cri/cri-spin-http-ts-example
EOF
cat >cri-spin-http-ts-example.web.ctr.yml <<'EOF'
metadata:
  name: web
image:
  image: ghcr.io/rgl/spin-http-ts-example:0.4.0
command:
  - /
log_path: web.log
EOF
pod_id="$(crictl runp \
  --runtime spin \
  cri-spin-http-ts-example.pod.yml)"
web_ctr_id="$(crictl create \
  $pod_id \
  cri-spin-http-ts-example.web.ctr.yml \
  cri-spin-http-ts-example.pod.yml)"
crictl start $web_ctr_id
web_ctr_ip="$(crictl inspectp $pod_id | jq -r .status.network.ip)"
wget -qO- "http://$web_ctr_ip"
crictl ps -a                    # list containers.
crictl inspect $web_ctr_id | jq # inspect container.
crictl logs $web_ctr_id         # dump container logs.
crictl pods                     # list pods.
crictl inspectp $pod_id | jq    # inspect pod.
crictl stopp $pod_id            # stop pod.
crictl rmp $pod_id              # remove pod.
rm -rf /var/log/cri/cri-spin-http-ts-example
```

### containerd ctr Usage

**NB** This is not yet working. See https://github.com/deislabs/containerd-wasm-shims/issues/202.

Use `ctr`:

```bash
ctr image pull \
  ghcr.io/rgl/spin-http-ts-example:0.4.0
ctr images list
ctr run \
  --detach \
  --runtime io.containerd.spin.v2 \
  --net-host \
  ghcr.io/rgl/spin-http-ts-example:0.4.0 \
  ctr-spin-http-ts-example
ctr sandboxes list # aka pods.
ctr containers list
ctr container rm ctr-spin-http-ts-example
```

# References

* [Spin JS/TS SDK](https://github.com/fermyon/spin-js-sdk)
* [Spin JS/TS SDK Examples](https://github.com/fermyon/spin-js-sdk/tree/main/examples)
* [Spin JS/TS @fermyon/spin-sdk NPM package](https://www.npmjs.com/package/@fermyon/spin-sdk)
* [Building Spin Components in JavaScript](https://developer.fermyon.com/spin/v3/javascript-components)
* [Done icon](https://icons8.com/icon/uw-X2j32n7Xp/done)
* [Creating a container image](https://github.com/deislabs/containerd-wasm-shims/blob/main/containerd-shim-spin/quickstart.md#creating-a-container-image)
