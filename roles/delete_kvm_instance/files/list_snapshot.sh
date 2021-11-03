#!/usr/bin/env bash

main() {
    local instance="$1"
    local snapshot

    while read snapshot _; do
        [[ ! -z "$snapshot" ]] && {
            echo "$snapshot"
        }
    done < <(virsh snapshot-list $instance | tail -n +3)

    return 0
}

main "$@"
