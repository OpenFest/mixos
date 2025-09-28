#!/usr/bin/env bash

set -euo pipefail
cdir="$(dirname "$(readlink -f "${0}")")"

function usage {
    echo "usage: ${1} (from-my-computer|to-my-computer) <patchbay name>"
    echo "synchronizes the files between this repo and the home directory of the user that runs the script"
    exit 1
}

function sync_from_home {
    cp -f "${HOME}"/.config/rncbc.org/qpwgraph.conf "${cdir}"/data/qpwgraph.conf
    cp -f "${HOME}"/.local/share/patchbays/main.qpwgraph "${cdir}"/data/patchbays/"${patchbay}".qpwgraph
}

function sync_to_home {
    mkdir -p ~/.config/rncbc.org ~/.local/share/patchbays
    cp -f "${cdir}"/data/qpwgraph.conf "${HOME}"/.config/rncbc.org/qpwgraph.conf
    cp -f "${cdir}"/data/patchbays/"${patchbay}".qpwgraph "${HOME}"/.local/share/patchbays/main.qpwgraph 
}

if [[ $# -ne 2 ]]; then
    usage "${0}"
fi

patchbay="${2}"

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

