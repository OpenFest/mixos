#!/usr/bin/env bash

set -euo pipefail
cdir="$(dirname "$(readlink -f "${0}")")"

function usage {
    echo "usage: ${1} (from-my-computer|to-my-computer)"
    echo "synchronizes the obs config dir between this repo and the home directory of the user that runs the script"
    exit 1
}

function sync_from_home {
    rsync -rva --delete-after --delete-excluded \
        --exclude=/logs \
        --exclude=/profiler_data \
        --exclude=/plugin_config/obs-browser \
        --exclude='*.bak' \
        --exclude=".version" \
        "${HOME}"/.config/obs-studio/ \
        "${cdir}"/obs-studio/
}

function sync_to_home {
    rsync -rva --delete-after --delete-excluded \
        "${cdir}"/obs-studio/ \
        "${HOME}"/.config/obs-studio/
}

if [[ $# -ne 1 ]]; then
    usage "${0}"
fi

case "${1}" in
    from-my-computer)
        sync_from_home
        ;;
    to-my-computer)
        sync_to_home
        ;;
    *)
        usage "${0}"
        ;;
esac

