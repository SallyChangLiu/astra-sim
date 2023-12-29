#!/bin/bash

# Absolue path to this script
SCRIPT_DIR=$(dirname "$(realpath $0)")
BUILD_DIR="${SCRIPT_DIR:?}"/build

# Absolute paths to useful directories
ASTRA_SIM_DIR="${SCRIPT_DIR:?}"/../../astra-sim
NS3_DIR="${SCRIPT_DIR:?}"/../../extern/network_backend/ns3
CHAKRA_ET_DIR="${SCRIPT_DIR:?}"/../../extern/graph_frontend/chakra/et_def

# Inputs - change as necessary.
WORKLOAD="${SCRIPT_DIR:?}"/../../extern/graph_frontend/chakra/one_comm_coll_node_allgather
SYSTEM="${SCRIPT_DIR:?}"/../../inputs/system/Switch.json
MEMORY="${SCRIPT_DIR:?}"/../../inputs/remote_memory/analytical/no_memory_expansion.json
LOGICAL_TOPOLOGY="${SCRIPT_DIR:?}"/../../inputs/network/ns3/sample_64nodes_1D.json
# Note that ONLY this file is relative to NS3_DIR/simulation
NETWORK="config/fat4.json"


# Functions
function setup {
    protoc et_def.proto\
        --proto_path ${SCRIPT_DIR}/../../extern/graph_frontend/chakra/et_def/\
        --cpp_out ${SCRIPT_DIR}/../../extern/graph_frontend/chakra/et_def/

    # make build directory if one doesn't exist
    if [[ ! -d "${BUILD_DIR:?}" ]]; then
      mkdir -p "${BUILD_DIR:?}"
    fi

    # set concurrent build threads, capped at 16
    NUM_THREADS=$(nproc)
    if [[ ${NUM_THREADS} -ge 16 ]]; then
      NUM_THREADS=16
    fi
}

function compile {
    # Only compile & Run the AstraSimNetwork ns3program
    cd "${NS3_DIR}"
    ./ns3 configure --enable-mtp --enable-examples
    ./ns3 build
    cd "${SCRIPT_DIR:?}"
}

function run {
    cd "${NS3_DIR}"
    ./ns3 run "AstraSimNetwork \
        --workload-configuration=${WORKLOAD} \
        --system-configuration=${SYSTEM} \
        --network-configuration=${NETWORK} \
        --remote-memory-configuration=${MEMORY} \
        --logical-topology-configuration=${LOGICAL_TOPOLOGY} \
        --comm-group-configuration=\"empty\""
    cd "${SCRIPT_DIR:?}"
}

function cleanup {
    cd "${NS3_DIR}"
    ./ns3 clean
    rm -rf "${BUILD_DIR:?}"
    cd "${SCRIPT_DIR:?}"
}

function cleanup_result {
    echo '0'
}

function debug {
    cd "${NS3_DIR}"
    ./ns3 configure --enable-mtp --enable-examples
    ./ns3 run 'AstraSimNetwork' --command-template="gdb --args %s ${NETWORK} \
        --workload-configuration=${WORKLOAD} \
        --system-configuration=${SYSTEM} \
        --remote-memory-configuration=${MEMORY} \
        --logical-topology-configuration=${LOGICAL_TOPOLOGY} \
        --comm-group-configuration=\"empty\""
}

function compile_astrasim_ns3() {
  # compile AstraSim
  cd "${BUILD_DIR:?}" || exit
  cmake ..
  cmake --build . -j "${NUM_THREADS:?}"
}

# Main Script
case "$1" in
-l|--clean)
    cleanup;;
-lr|--clean-result)
    cleanup
    cleanup_result;;
-d|--debug)
    setup
    compile_astrasim_ns3
    debug;;
-c|--compile)
    setup
    compile_astrasim_ns3
    compile;;
-r|--run)
    setup
    compile_astrasim_ns3
    compile
    run;;
-h|--help|*)
    printf "Prints help message";;
esac
