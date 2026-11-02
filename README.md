# llm-d-infra-providers

Community-owned infrastructure provisioning tooling and guides for preparing Kubernetes clusters to run [llm-d](https://github.com/llm-d/llm-d).

> **Status: incubation.** This repository implements the
> *Community-Driven Infrastructure Provisioning & Conformance Strategy for llm-d*
> ([RFC llm-d/llm-d#2168](https://github.com/llm-d/llm-d/issues/2168), created via
> [llm-d/llm-d#2427](https://github.com/llm-d/llm-d/issues/2427)), with GKE as the
> first provider, under the `llm-d-incubation` organization per the
> [llm-d project rules](https://github.com/llm-d/llm-d/blob/main/PROJECT.md#source-code).

## Purpose and Goal

Setting up an environment for `llm-d` involves two layers:

1. **Infrastructure provisioning**: preparing a Kubernetes cluster with hardware
   accelerators, high-performance networking (RDMA, RoCE, InfiniBand), device and
   DRA drivers, Gateway API, and storage prerequisites so the cluster is ready to
   host `llm-d`.
2. **Stack installation**: deploying the `llm-d` software components, documented
   by the [llm-d well-lit path guides](https://github.com/llm-d/llm-d/tree/main/guides).

This repository is the community-owned entry point for layer 1: provisioning
guides, scripts, infrastructure-as-code templates, AI skills, and cluster
readiness conformance checks. Core llm-d owns layer 2 and does not host
per-provider provisioning tooling.

## Repository layout

```
cloud-providers/      Per-cloud-provider provisioning tooling and docs
  gke/                Google Kubernetes Engine (pilot provider)
  aks/                Azure Kubernetes Service
  digitalocean/       DigitalOcean Kubernetes
  eks/                Amazon Elastic Kubernetes Service
  minikube/           minikube (single-host development)
  openshift/          OpenShift Container Platform
  openshift-aws/      OpenShift on AWS
gateway-providers/    Gateway control-plane prerequisites (GKE Gateway, Istio, agentgateway, Envoy AI Gateway)
storage-providers/    Storage prerequisites (model weights, caches)
conformance/          Infra Conformance Suite: dimension-labeled executable checks
```

Each provider directory is maintained by its own provider owners via a
per-directory `OWNERS` file.

## Ownership model

* Each `cloud-providers/<name>/`, `gateway-providers/<name>/`, and
  `storage-providers/<name>/` sub-folder has its own `OWNERS` file. Provider
  owners review and approve PRs touching their sub-folder.
* Repository approvers (root [OWNERS](OWNERS)) curate repository structure, the
  conformance framework, and cross-provider consistency. They do not gate
  provider-internal changes.

See [GOVERNANCE.md](GOVERNANCE.md).

## Provisioning methods

Providers may offer any combination of the following methods. All methods must
converge on the same end state: a cluster that passes the conformance suite for
the dimension profiles the provider claims to support.

| Method | Properties |
|---|---|
| Guided documentation | Transparent, easy to follow manually; prone to bit rot |
| Deterministic scripts / IaC (Terraform, shell) | Reproducible, automatable; less adaptable |
| AI skills | Interactive, adaptable to context; requires anchoring in docs to avoid drift |

## Conformance

The [Infra Conformance Suite](conformance/README.md) is the qualification bar for
every provider directory. It is a collection of executable checks, each labeled
with the [dimensions](conformance/dimensions.yaml) it applies to
(`infra_provider`, `accelerator`, `rdma`, `dra`, `router_mode`,
`gateway_provider`, ...). Given a target dimension profile, the runner filters
the applicable checks and executes them against the current kubeconfig context:

```bash
conformance/bin/llmd-infra-check --profile conformance/profiles/gke-pd-disaggregation.yaml
# add active fabric tests (creates pods on GPU nodes):
conformance/bin/llmd-infra-check --profile conformance/profiles/gke-pd-disaggregation.yaml --microtests
```

Static checks verify node readiness, accelerator exposure (device plugin or DRA
ResourceSlices), RDMA network attachment, and Gateway API/Inference Extension
CRDs. Micro-tests actively validate the fabric: a two-node NCCL collective test
and a pod-to-pod NIXL transfer benchmark. Captured runs from live clusters are in
[conformance/examples/](conformance/examples/).

> Per the RFC, the conformance suite's target home is the core llm-d repository
> so that discovery and consistency checking are centralized. It is hosted here
> during incubation; the runner and check contract are designed to move without
> modification.

## Provider status

| Provider | Owners | Methods | Qualified profiles |
|---|---|---|---|
| [gke](cloud-providers/gke/) | see `cloud-providers/gke/OWNERS` | docs, scripts, AI skill | `gke-optimized-baseline`, `gke-pd-disaggregation`, `gke-wide-ep-lws`, `gke-a4x-pd-disaggregation` |
| [aks](cloud-providers/aks/) | needed | docs (migrated from llm-d) | - |
| [digitalocean](cloud-providers/digitalocean/) | needed | docs (migrated from llm-d) | - |
| [eks](cloud-providers/eks/) | needed | scaffold; EFA conformance check | - (`eks-pd-disaggregation` pending) |
| [minikube](cloud-providers/minikube/) | needed | docs (migrated from llm-d) | - |
| [openshift](cloud-providers/openshift/) | needed | docs (migrated from llm-d) | - |
| [openshift-aws](cloud-providers/openshift-aws/) | needed | docs (migrated from llm-d) | - |

"Qualified profiles" lists the conformance profiles the provider's tooling has
been validated against. Providers without owners carry documentation migrated
from `llm-d/docs/infrastructure` as-is and need a maintainer to progress.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the workflow and how to add a
provider, and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community
expectations. To report a vulnerability, follow [SECURITY.md](SECURITY.md)
rather than opening a public issue.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
