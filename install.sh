#!/usr/bin/env bash
set -Eeuo pipefail
[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && echo "Bash >= 4 required" && exit 1

function show_usage() {
    cat >&2 << EOF
Usage: ${SCRIPT_NAME} [OPTION...]
  --cal           Specify the CalDAV URL to use
  --card          Specify the CardDAV URL to use
  -u, --uninstall Uninstall the service
  -h, --help      Show this help message then exit
EOF
}

SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
readonly SCRIPT_DIR

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

readonly SERVICE_NAME="gnome-dav-shim"
readonly BIN_DIR=~/.local/bin
readonly BIN_FILE="${BIN_DIR}/gnome-dav-support"
readonly SYSTEMD_UNIT_DIR=~/.config/systemd/user
readonly SYSTEMD_UNIT_FILE="${SYSTEMD_UNIT_DIR}/${SERVICE_NAME}.service"

function panic() {
    >&2 echo "FATAL: ${*}"
    exit 1
}

ARG_CAL="fastmail"
ARG_CARD="fastmail"

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "${1}" in
            --cal)
                test "${#}" -ge 2 || panic "Missing CalDAV URL / provider"
                ARG_CAL="${2}"
                consume=2
            ;;
            --card)
                test "${#}" -ge 2 || panic "Missing CardDAV URL / provider"
                ARG_CARD="${2}"
                consume=2
            ;;
            -u|--uninstall)
                ARG_UNINSTALL="true"
            ;;
            -h|-\?|--help)
                ARG_HELP="true"
            ;;
            *)
                >&2 echo "Unrecognized argument: ${1}"
                show_usage
                exit 1
            ;;
        esac

        shift ${consume}
    done
}

parse_commandline "${@}"

if [ "${ARG_HELP:-}" = "true" ]; then
    show_usage
    exit 0
fi

function unexpected_error() {

    local line_num="${1}"
    local script_path="${2}"
    local faulting_command="${3}"
    
    cat <<EOF
Unexpected error at line ${line_num} ${script_path}:
    Command: "${faulting_command}"
EOF

}

trap 'unexpected_error ${LINENO} ${BASH_SOURCE[0]} ${BASH_COMMAND}' ERR   # Single-quotes are important, see https://unix.stackexchange.com/a/39660

test "$(id --user)" -ne 0 || echo "WARNING: This script is being run as root; that may not be what you want."

function service_exists() {
    systemctl list-unit-files --full --type=service --user \
        | grep --fixed-strings "${SERVICE_NAME}.service" > /dev/null
}

function install_service() {

    service_exists && panic "Service is already installed."

    test -d "${SYSTEMD_UNIT_DIR}" || mkdir --parent "${SYSTEMD_UNIT_DIR}"
    test -d "${BIN_DIR}" || mkdir --parent "${BIN_DIR}"

    cp "${SCRIPT_DIR}/out/gnome-dav-support" "${BIN_DIR}"

    (cat <<EOF
[Unit]
Description=GNOME DAV support shim
Wants=network.target
After=network-online.target

[Service]
ExecStart=${BIN_DIR}/gnome-dav-support --cal "${ARG_CAL}" --card "${ARG_CARD}"
Restart=always

[Install]
WantedBy=default.target
EOF
    ) > "${SYSTEMD_UNIT_FILE}"

    systemctl daemon-reload --user
    systemctl enable --user --now "${SERVICE_NAME}"
}

function uninstall_service() {

    service_exists || panic "Service is not installed yet."

    if systemctl is-active --user "${SERVICE_NAME}" > /dev/null; then
        systemctl stop --user "${SERVICE_NAME}"
    fi

    if systemctl is-enabled --user "${SERVICE_NAME}" > /dev/null; then
        systemctl disable --user "${SERVICE_NAME}"
    fi

    test -f "${SYSTEMD_UNIT_FILE}" && rm "${SYSTEMD_UNIT_FILE}"
    test -f "${BIN_FILE}" && rm "${BIN_FILE}"

    systemctl --user daemon-reload
}

function main() {
    if [ "${ARG_UNINSTALL:-}" = "true" ]; then
        uninstall_service
    else
        install_service
    fi
}

main
