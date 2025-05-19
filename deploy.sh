#!/bin/bash

set -euo pipefail

cdir="$(dirname "$(readlink -f "${0}")")"

function msg {
    echo "${@}" >&2
}

function die {
    if [[ ${#} -ge 1 ]]; then
        msg "${@}"
    fi
    exit 1
}

function usage {
    msg "usage:"
    msg "${0} sync      <configuration> <remote ssh host>    # sync this repo to remote host, build on remote host, deploy there locally"
    msg "${0} remote    <configuration> <remote ssh host>    # build locally, deploy to remote host"
    msg "${0} local     <configuration>                      # build and deploy on this machine"
    msg "${0} image     <configuration>                      # build a bootable disk image and put it in result/"
    msg "${0} image-on  <configuration> <device>             # build a bootable disk image and burn it to given device (will call sudo automatically when needed)"
    die
}

function require_rsync {
    if which rsync &>/dev/null; then
        return
    fi
    die "this script requires rsync to be installed. please use your package manager to install it"
}

function user_wants {
    read -p "${1} (y/n) " -n 1 -r reply
    if [[ "${reply}" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

function require_nix {
    if which nix &>/dev/null; then
        return
    fi
    msg "this script requires nix to be installed."
    if user_wants "do you want to install it now? "; then
        sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
        require_nix
        return
    fi
    die "please install nix and run me again"
}

function deploy_with_sync {
    require_rsync
    ssh_to=human@"${1}"
    rsync -rvzza --progress --info=progress2 "${cdir}"/ "${ssh_to}":mixos/
    ssh "${ssh_to}" "sudo bash ~/mixos/deploy.sh local '${conf_name}'"
}

function deploy_local {
    cd "${cdir}"
    require_nix
    nix run '.#deploy-local' "${conf_name}"
}

function deploy_remote {
    cd "${cdir}"
    ssh_to=root@"${1}"
    require_nix
    nix run '.#deploy' "${conf_name}" "${ssh_to}"
}

function build_image {
    cd "${cdir}"
    require_nix
    nix build ".#images.${conf_name}"
}

function burn_image {
    local cmd
    if [[ -w "${1}" ]]; then
        cmd=(dd)
    else
        cmd=(sudo dd)
    fi

    "${cmd[@]}" if=./result/nixos.img of="${1}" bs=4M status=progress oflag=direct
}

if [[ ${#} -lt 2 ]]; then
    usage
fi

action="${1}"
conf_name="${2}"

case "${action}" in
    sync)
        [[ ${#} -ne 3 ]] && usage || true
        deploy_with_sync "${3}"
        ;;
    remote)
        [[ ${#} -ne 3 ]] && usage || true
        deploy_remote "${3}"
        ;;
    local)
        [[ ${#} -ne 2 ]] && usage || true
        deploy_local
        ;;
    image)
        [[ ${#} -ne 2 ]] && usage || true
        build_image
        ;;
    image-on)
        [[ ${#} -ne 3 ]] && usage || true
        build_image
        burn_image "${3}"
        ;;
    *)
        usage
        ;;
esac
