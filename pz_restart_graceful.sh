#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

declare -i DEFAULT_RESTART_MINS=30
declare -i ALERT_EVERY_MIN=5

# shellcheck source=./pz.bashrc
source /usr/local/etc/pz.bashrc
if [[ -f /usr/local/etc/pz.bashrc.local ]]; then
  # use this file to specify any overrides
  source /usr/local/etc/pz.bashrc.local
fi

function main() {
  local restartMins="${1:-${DEFAULT_RESTART_MINS}}"
  local restartReason="${2:-}"

  # assure value is an integer
  printf -v restartMins '%0.f' "${restartMins}"
  if [[ ${restartMins} -le 0 ]]; then
    # check for zero/negative as well
    restartMins="${DEFAULT_RESTART_MINS}"
  fi

  local -i remainingTime=${restartMins}
  while [[ ${remainingTime} -gt 0 ]]; do
    remainingTime=$(checkPlayerCountAndBroadcast "${remainingTime}" "${restartReason}")
    remainingTime=$(sleepAndReduceBy "${remainingTime}" "${ALERT_EVERY_MIN}")
  done

  restartAndBackup
}

function checkPlayerCountAndBroadcast() {
  local -i remainingTime=${1}
  local restartReason="${2:-}"

  local -i playerCount
  playerCount=$(getPlayerCount)
  if [[ ${playerCount} -eq 0 ]]; then
    # signal to immediately shutdown
    echo 0
    return
  fi
  local broadcastMsg="SERVER RESTART IN ${remainingTime} MINUTES"
  if [[ -n "${restartReason}" ]]; then
    broadcastMsg+=".<LINE>REASON: ${restartReason}"
  fi
  pz_broad "${broadcastMsg}" >/dev/null 2>&1
  echo "${remainingTime}"
}

function getPlayerCount() {
  local rconPlayersResponse rconPlayersHeader playerCount
  rconPlayersResponse="$(pz_players)"
  rconPlayersHeader="$(head -n1 <<< "${rconPlayersResponse}")"
  # NOTE: if pz changes any of its output to commands this will "break"
  playerCount="$(sed -E 's/.*players connected \(([0-9]+)\).*/\1/i' <<< "${rconPlayersHeader}")"

  # we'll make it smart, so if regex fails (same text after processing) we assume there are players
  if [[ -z "${playerCount}" || "${rconPlayersHeader}" == "${playerCount}" ]]; then
    echo "WARNING: regex failed to detect player count. Response: ${rconPlayersResponse}" 1>&2
    # need some special #, one is as good as the next :P
    echo 69
    return
  fi

  if [[ ${playerCount} -gt 0 ]]; then
    # for logging purposes print to stderr the users shown logged in
    echo -e "STILL LOGGED IN:\n$(tail -n +2 <<< "${rconPlayersResponse}")" 1>&2
  fi

  echo "${playerCount}"
}

function restartAndBackup() {
  pz_broad 'FLEE FLEE FLEE'
  pz_stop
  sleep 1s
  pz_create_backup
  pz_start
}

function sleepAndReduceBy() {
  local -i current=${1}
  local -i reduceByNearest=${2}

  local -i reduceBy
  if [[ ${current} -eq 0 ]]; then
    # immediately bail
    echo 0
    return
  elif [[ ${current} -le 1 ]]; then
    # final iteration
    reduceBy=1
    current=0
  elif [[ ${current} -gt ${reduceByNearest} ]]; then
    local -i remainder
    remainder=$((current % reduceByNearest))
    if [[ ${remainder} -ne 0 ]]; then
      reduceBy=${remainder}
    else
      reduceBy=${reduceByNearest}
    fi
    ((current-=reduceBy))
  else
    # we want to sleep until current=1
    local -i remainder
    remainder=$((current % reduceByNearest))
    if [[ ${remainder} -ne 0 ]]; then
      reduceBy=$((remainder - 1))
    else
      reduceBy=$((reduceByNearest - 1))
    fi
    ((current-=reduceBy))
  fi
  sleep "${reduceBy}m"
  echo "${current}"
}

main "$@"
