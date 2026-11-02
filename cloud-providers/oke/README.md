# OKE infrastructure provider for llm-d

Provisioning tooling and documentation for preparing Oracle Kubernetes Engine
(OKE) clusters to run llm-d.

**Status: scaffold.** Owners are listed in [OWNERS](OWNERS). Nothing here is
qualified against the conformance suite yet.

## Supported configurations

Shapes with an llm-d guide overlay today:

| Shape | Accelerator | RDMA | llm-d overlay |
|---|---|---|---|
| `BM.GPU.MI300X.8` | AMD MI300X (`amd.com/gpu`) | RoCE via NVIDIA Network Operator SR-IOV VFs (`nvidia.com/sriov-rdma-vf`) | pd-disaggregation `amd/vllm/nixl/oci` |
| `BM.GPU.GB200.4` | NVIDIA GB200 | TBD by owners | models/deepseek-v4 (tested on OCI) |

AMD and NVIDIA shapes are provisioned and deployed differently (see the
`values_oci_amd` naming request on llm-d/llm-d#1123), so each gets its own
networking path and conformance profile rather than a shared one.

## Networking paths

| Path | Dimension profile | Target guide | Provision with |
|---|---|---|---|
| AMD MI300X + SR-IOV RoCE | `accelerator=amd rdma=roce dra=none` | pd-disaggregation (`nixl/oci` overlay) | [oci-hpc-oke](https://github.com/oracle-quickstart/oci-hpc-oke) (external) |
| NVIDIA GPU | TBD | TBD | [oci-hpc-oke](https://github.com/oracle-quickstart/oci-hpc-oke) (external) |

## Provisioning methods

1. **Infrastructure as Code (Terraform)** -
   [oracle-quickstart/oci-hpc-oke](https://github.com/oracle-quickstart/oci-hpc-oke)
   (external) provisions GPU and RDMA clusters on OKE.
2. **Guided documentation** - TODO (`docs/`).

## Qualification against the conformance suite

| Profile | Status |
|---|---|
| `oke-amd-pd-disaggregation` | check selection validated; cluster run pending |

Run:

```bash
conformance/bin/llmd-infra-check --profile conformance/profiles/oke-amd-pd-disaggregation.yaml
```

Gap: no check yet verifies `nvidia.com/sriov-rdma-vf` allocatable or the
`sriov-rdma-vf` SriovNetwork; only the common checks apply to this profile.

## Known issues to surface at deploy time

From the llm-d `nixl/oci` overlay:

* **`IPC_LOCK`** capability is required for UCX/RDMA over SR-IOV VFs.
* **`UCX_IB_GID_INDEX`** is typically `3` on OCI; verify with `show_gids` on
  the host.
* The overlay expects the `sriov-rdma-vf` SriovNetwork in namespace `default`
  and one VF per GPU in the tensor-parallel group.
