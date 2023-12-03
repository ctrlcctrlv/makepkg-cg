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
    local ESCAPED_MAKEPKG_ARGS=$(printf '%q %s ' "${0%%-cg}" "${MAKEPKG_ARGS[@]}")

    # Create a transient .slice unit for this invocation of makepkg-cg
    local SLICE_NAME="makepkg-cg-${USER_ID}-$(date +%s%N).slice"
    # Echo to user…
    local LOGENTRY="Running slice: $SLICE_NAME — $ESCAPED_MAKEPKG_ARGS"
    >&2 echo $LOGENTRY
    # …and to syslog
    command -v logger >/dev/null && \
        logger -t makepkg-cg -- $LOGENTRY
    systemd-run --user --slice "${SLICE_NAME}" \
        $(for key in "${MAKEPKG_ENV[@]}"; do local value="${MAKEPKG_ENV[$key]}"; echo -n "--setenv=$key=$value "; done) \
        --wait --send-sighup --same-dir --pty --service-type=exec \
        --property="CPUSchedulingPolicy=${CPU_POLICY}" \
        --property="CPUQuota=${CPU_PERCENT}" \
        --property="MemoryHigh=${RAM_PERCENT}" \
        --property="MemoryMax=${RAM_MAX}" \
        --property="MemorySwapMax=${SWAP_MAX}" \
        --property="IOSchedulingClass=${IO_CLASS}" \
        --property="IOSchedulingPriority=${IO_LEVEL}" \
        ${ESCAPED_MAKEPKG_ARGS} \
        #--property="IPIngressFilterPath=${EBPF_PROGRAM_PATH}" \
        #--property="IPEgressFilterPath=${EBPF_PROGRAM_PATH}" \
    wait $!
    [ $DEBUG -eq 0 ] && systemctl --user stop "$SLICE_NAME"
    [ $DEBUG -eq 0 ] && set +x
}

## vim: ts=4 et sw=4 syntax=bash
