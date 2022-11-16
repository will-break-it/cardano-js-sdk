#!/usr/bin/env bash

# This script updates SPO11: This SPO will be retired at epoch 18, has metadata and meets the pledge.
set -euo pipefail

here="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
root="$(cd "$here/../.." && pwd)"
cd "$root"
export PATH=$PWD/bin:$PATH

# pool parameters
SPO_NODE_ID=11
RETIRING_EPOCH=18
POOL_PLEDGE=400000000
POOL_OWNER_STAKE=500000000 # Must be greater than pledge
POOL_COST=390000000
POOL_MARGIN=0.15
METADATA_URL="http://file-server/SP${SPO_NODE_ID}.json"

source ./scripts/pools/update-node-utils.sh

trap clean EXIT

updatePool ${SPO_NODE_ID} ${POOL_PLEDGE} ${POOL_OWNER_STAKE} ${POOL_COST} ${POOL_MARGIN} ${METADATA_URL}
deregisterPool ${SPO_NODE_ID} ${RETIRING_EPOCH}
