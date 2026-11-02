# EKS infrastructure provider for llm-d

Provisioning tooling and documentation for preparing Amazon Elastic Kubernetes
Service (EKS) clusters to run llm-d.

**Status: scaffold, owners needed.** To adopt this provider, add yourself to
[OWNERS](OWNERS) (see [CONTRIBUTING.md](../../CONTRIBUTING.md)).

## Supported configurations

Shapes with an llm-d guide overlay today: `p5en.48xlarge` (NVIDIA H200) with
Elastic Fabric Adapter (EFA), used by the pd-disaggregation `aws` overlays for
vLLM and SGLang. The overlays request `vpc.amazonaws.com/efa` (8 per decode
pod, 2 per prefill pod in the vLLM overlay), so the cluster needs the
[EFA device plugin](https://github.com/aws/eks-charts/tree/master/stable/aws-efa-k8s-device-plugin).

## Networking paths

| Path | Dimension profile | Target guide | Provision with |
|---|---|---|---|
| EFA (libfabric) | `rdma=efa dra=none` | pd-disaggregation (`aws` overlay) | TODO |
| No RDMA (aggregated serving) | `rdma=none dra=none` | optimized-baseline and other single-node guides | any EKS GPU node group |

## Provisioning methods

None yet. Contributions welcome (docs, eksctl/Terraform, or an AI skill).

## Qualification against the conformance suite

| Profile | Status |
|---|---|
| `eks-pd-disaggregation` | check selection validated; `eks.efa-device-resources` tested against a fake kubectl; cluster run pending |

Run:

```bash
conformance/bin/llmd-infra-check --profile conformance/profiles/eks-pd-disaggregation.yaml
```

## Known issues to surface at deploy time

From the llm-d [RDMA guide](https://github.com/llm-d/llm-d/blob/main/docs/infrastructure/rdma/README.md):

* **NIXL uses the libfabric backend on EFA**, not UCX (UCX does not support
  EFA). UCCL also works with `UCCL_P2P_TRANSPORT=efa` but must be built with
  `USE_EFA`.
* **libfabric v1.21.0+** (or the latest AWS EFA installer) is required.
* The libfabric plugin maps GPUs to EFA devices through hwloc for multi-rail
  placement.
* The llm-d page marks its AWS section deprecated in favour of upstream AWS
  images; the guide overlays use the `gpu-vllm/aws-efa` image component.
