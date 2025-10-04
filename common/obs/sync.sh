#!/usr/bin/env bash

set -euo pipefail
cdir="$(dirname "$(readlink -f "${0}")")"

function usage {
    echo "usage: ${1} (from-my-computer|to-my-computer|from-host <hostname>)"
    echo "synchronizes the obs config dir between this repo and the home directory of the user that runs the script"
    exit 1
}

function sync_from_dir {
    rsync -rva --delete-after --delete-excluded \
        --exclude=/logs \
        --exclude=/profiler_data \
        --exclude=/plugin_config/obs-browser \
        --exclude='*.bak' \
        --exclude=".version" \
        "${1}" \
        "${cdir}"/obs-studio/
}

function sync_from_home {
    sync_from_dir "${HOME}/.config/obs-studio/"
}

function sync_from_remote {
    sync_from_dir "${1}:.config/obs-studio/"
}

function sync_to_home {
    rsync -rva --delete-after --delete-excluded \
        "${cdir}"/obs-studio/ \
        "${HOME}"/.config/obs-studio/
}

if [[ $# -eq 0 ]]; then
    usage "${0}"
fi

case "${1}" in
    from-host)
        if [[ $# -ne 2 ]]; then
            usage "${0}"
        fi
        sync_from_remote "${2}"
        ;;
    from-my-computer)
        if [[ $# -ne 1 ]]; then
            usage "${0}"
        fi
        sync_from_home
        ;;
    to-my-computer)
        if [[ $# -ne 1 ]]; then
            usage "${0}"
        fi
        sync_to_home
        ;;
    *)
        usage "${0}"
        ;;
esac

