#!/bin/bash

# makepkg-cg: A makepkg wrapper using Control Groups via systemd.resource-control

makepkg-cg() {
    # Get user ID
    local USER_ID="$(id -u)"

    # Set default resource limits (see doc/makepkg-cg.conf)
    local CPU_PERCENT=$(( `nproc` * 75 ))"%"
    local CPU_POLICY=idle
    local RAM_PERCENT="75%"
    local RAM_MAX="90%"
    local IO_LEVEL="7"
    local IO_CLASS=idle
    local SWAP_MAX=0

    # Debug?
    local DEBUG=0

    # Set default eBPF program path
    # TODO: Fix this.
    # local EBPF_PROGRAM_PATH="/usr/share/makepkg-cg/makepkg_cg_prio.bpf.o"

    # Load custom limits and eBPF program path from a configuration file
    local CONFIG_FILE="${HOME}/.config/makepkg-cg.conf"
    if [[ -f "${CONFIG_FILE}" ]]; then
        source "${CONFIG_FILE}"
    fi

    [ $DEBUG -eq 1 ] && set -x

	# Prepare arguments for makepkg
	local MAKEPKG_ARGS="${@}"
	local ESCAPED_MAKEPKG_ARGS=$(printf '%q ' "${MAKEPKG_ARGS[@]}")

	# Create a transient .slice unit for this invocation of makepkg-cg
	local SLICE_NAME="makepkg-cg-${USER_ID}-$(date +%s%N).slice"
    >&2 echo "Running slice: $SLICE_NAME"
	systemd-run --user --slice "${SLICE_NAME}" \
        --wait --send-sighup --same-dir --pty --service-type=exec \
        --property="CPUSchedulingPolicy=${CPU_POLICY}" \
        --property="CPUQuota=${CPU_PERCENT}" \
        --property="MemoryHigh=${RAM_PERCENT}" \
        --property="MemoryMax=${RAM_MAX}" \
        --property="MemorySwapMax=${SWAP_MAX}" \
        --property="IOSchedulingClass=${IO_CLASS}" \
        --property="IOSchedulingPriority=${IO_LEVEL}" \
        $MAKEPKG_CG_PROGRAM "$@" &
        #--property="IPIngressFilterPath=${EBPF_PROGRAM_PATH}" \
        #--property="IPEgressFilterPath=${EBPF_PROGRAM_PATH}" \
    wait $!
    [ $DEBUG -eq 0 ] && systemd --user stop "$SLICE_NAME"
    [ $DEBUG -eq 0 ] && set +x
}

## vim: ts=4 et sw=4 syntax=bash
