#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

declare -r DEFAULT_SLEEP=120

# shellcheck source=./pz.bashrc
source /usr/local/etc/pz.bashrc
if [[ -f /usr/local/etc/pz.bashrc.local ]]; then
  # use this file to specify any overrides
  source /usr/local/etc/pz.bashrc.local
fi

function main() {
  # expected to run immediately after startup, so warmup is necessary
  # TODO: switch to poll and wait method design, we can more quickly return once we find pz-server started
  #  measure total wait time between individual attempts, separate both low level nc port check, and rcon cmd test
  sleep "${DEFAULT_SLEEP}"

  # first check if rcon port is even open
  isPortListening "127.0.0.1" "27015" || {
    echo "PZ Server post-startup: not listening on expected port (27015)" 1>&2;
    return 1;
  }

  # do a simple RCON message to see if server is listening
  local rconPlayersResponse rconPlayersHeader playerCount
  rconPlayersResponse="$(pz_players)"
  rconPlayersHeader="$(head -n1 <<< "${rconPlayersResponse}")"
  # NOTE: if pz changes any of its output to command this will "break"
  playerCount="$(sed -E 's/.*players connected \(([0-9]+)\).*/\1/i' <<< "${rconPlayersHeader}")"

  if [[ -z "${playerCount}" || "${rconPlayersHeader}" == "${playerCount}" ]]; then
    # if regex fails that means rconPlayersHeader==playerCount
    # which will occur either because command response changed (must update regex)
    # or the server isn't properly responding. we checked that the port is open, but if we don't get a good response that
    # may indicate a need to restart
    echo "PZ Server post-startup: Unexpected response - ${rconPlayersResponse}" 1>&2
    return 2
  fi

  return 0
}

function isPortListening() {
  local host="${1}"
  local port="${2}"

  nc -z -w5 "${host}" "${port}"
}

main "$@"
