#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

declare -r STEAMCMD_HOME=/opt/steamcmd
declare -r STEAMCMD_USER=steam
declare -r STEAMCMD_INSTALLER='https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz'

function main() {
  if [[ $EUID -ne 0 ]]; then
    echo 'ERROR: script must be run with root privileges.'
    exit 1
  fi

  if [[ "${1:-}" == '--clean' ]]; then
    rm -Rf "${STEAMCMD_HOME}"
  fi

  # necessary dependencies
  dpkg --add-architecture i386
  apt-get update -q=2 -y
  apt-get install -y lib32gcc1 default-jdk-headless libsdl2-2.0-0:i386

  # create user if does not exist
  getent passwd "${STEAMCMD_USER}" >/dev/null || adduser --system --group --home "${STEAMCMD_HOME}" "${STEAMCMD_USER}"

  mkdir -p "${STEAMCMD_HOME}"
  # extract steamcmd
  wget -nv -O- "${STEAMCMD_INSTALLER}" | tar xzf - --no-same-owner --no-same-permissions -C "${STEAMCMD_HOME}"

  chown -R "${STEAMCMD_USER}:${STEAMCMD_USER}" "${STEAMCMD_HOME}"

  # perform first run
  sudo -u "${STEAMCMD_USER}" -s /bin/bash "${STEAMCMD_HOME}/steamcmd.sh" +login anonymous +quit
}

main "$@"
