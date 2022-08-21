#!/usr/bin/env bash

main() {
    output=$(virsh net-list --all | tail -n +3 | grep -P '^ default\s+')

    if [ -z "$output" ]; then
        echo "ERROR: Failed to get output of \"virsh net-list --all\". An output of the command was empty."
        return 1
    fi
    read virsh_name virsh_state virsh_autostart _ <<< "$output"

    if [ "$virsh_name" != "default" ]; then
        echo "ERROR: There is not a network \"default\" in the environment with a command \"\"." >&2
        return 1
    fi

    if [ ! "$virsh_state" = "active" ]; then
        virsh net-start default || {
            echo "ERROR: Failed to start virsh-network start." >&2
            return 1
        }
    fi

    if [ ! "$virsh_autostart" = "yes" ]; then
        virsh net-autostart default
        result=$?
        if [ $result -ne 0 ]; then
            echo "ERROR: Failed to set autostart. A return code of the command \"virsh net-autostart default\" was ${result}" >&2
            return 1
        fi
    fi

    return $result
}

main "$@"
