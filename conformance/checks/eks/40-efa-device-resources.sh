#!/usr/bin/env bash
# conformance-check
# id: eks.efa-device-resources
# description: EFA device plugin advertises vpc.amazonaws.com/efa on GPU nodes (requested by the llm-d aws overlays)
# dimensions: infra_provider=eks rdma=efa
set -euo pipefail
. "$LLMD_CONFORMANCE_ROOT/lib/common.sh"

require_cmd kubectl
# One line per node: <name>|<nvidia.com/gpu>|<vpc.amazonaws.com/efa> (empty when absent).
# "|" not whitespace: read collapses adjacent whitespace, so an empty GPU field
# would shift the EFA count into it.
efa_total=0 efa_nodes=0 gpu_nodes=0 gpu_no_efa=""
while IFS='|' read -r name gpu efa; do
  [ -n "$name" ] || continue
  [ -n "${gpu:-}" ] && [ "$gpu" -gt 0 ] && gpu_nodes=$((gpu_nodes + 1))
  if [ -n "${efa:-}" ] && [ "$efa" -gt 0 ]; then
    efa_nodes=$((efa_nodes + 1)); efa_total=$((efa_total + efa))
  elif [ -n "${gpu:-}" ] && [ "$gpu" -gt 0 ]; then
    gpu_no_efa="$gpu_no_efa $name"
  fi
done < <(k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"|"}{.status.allocatable.nvidia\.com/gpu}{"|"}{.status.allocatable.vpc\.amazonaws\.com/efa}{"\n"}{end}')

[ "$efa_total" -gt 0 ] || fail "no node advertises allocatable vpc.amazonaws.com/efa (EFA device plugin missing, or instance type without EFA)"
[ -z "$gpu_no_efa" ] || echo "warning: GPU node(s) without EFA:$gpu_no_efa (pods requesting vpc.amazonaws.com/efa will not schedule there)"
pass "$efa_total allocatable vpc.amazonaws.com/efa on $efa_nodes node(s); $gpu_nodes GPU node(s)"
