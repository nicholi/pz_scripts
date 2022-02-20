#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

declare -r PZ_STEAM_APPID=108600
declare -r PZ_SERVER_STEAM_APPID=380870

# parseable by date
declare SERVICE_RUNNING_OLDER_THAN='1 min ago'

# shellcheck source=./pz.bashrc
source /usr/local/etc/pz.bashrc
if [[ -f /usr/local/etc/pz.bashrc.local ]]; then
  # use this file to specify any overrides
  source /usr/local/etc/pz.bashrc.local
fi

function main() {
  local systemdServiceJson activeState subState activeEnterTimestamp
  systemdServiceJson="$(systemctl show -p "ActiveState" -p "SubState" -p "ActiveEnterTimestamp" pz-server.service | \
    jq -c --slurp --raw-input 'split("\n") | map(select(. != "") | split("=") | {"key": .[0], "value": (.[1:] | join("="))}) | from_entries')"
  read -r -d '' activeState subState activeEnterTimestamp \
    < <(jq -r '[.ActiveState, .SubState, .ActiveEnterTimestamp] | map("__"+.) | join("\n")' <<< "${systemdServiceJson}"; printf '\0';)
  # handle empty strings, prefixed with __
  activeState="${activeState#__}"
  subState="${subState#__}"
  activeEnterTimestamp="${activeEnterTimestamp#__}"

  if [[ "${activeState}" != 'active' || "${subState}" != 'running' ]]; then
    # service not currently running, may be offline or in middle of restarting phase from previous workshop-update
    echo "Service not online. ActiveState=${activeState}. SubState=${subState}" 
    return
  fi
  # or has started less than 1 minute ago
  if [[ "$(date --date "${activeEnterTimestamp}" '+%s')" -ge "$(date --date "${SERVICE_RUNNING_OLDER_THAN}" '+%s')" ]]; then
    echo "Service only recently started. ActiveEnterTimestamp=${activeEnterTimestamp}. CurrentTimestamp=$(date)"
    return
  fi

  local broadcastMsg=''

  # check pz buildid
  local zomboidGameAcfFile="${PZ_HOME}/steamapps/appmanifest_${PZ_SERVER_STEAM_APPID}.acf"
  local buildIdUpdated
  buildIdUpdated="$(checkProjectZomboidBuildId "${zomboidGameAcfFile}")"

  if [[ -n "${buildIdUpdated}" ]]; then
    echo "${buildIdUpdated}"
    broadcastMsg="${buildIdUpdated}"
  fi

  # else finally check workshop items
  local zomboidWorkshopAcfFile="${PZ_HOME}/steamapps/workshop/appworkshop_${PZ_STEAM_APPID}.acf"
  local workshopItemsUpdated
  workshopItemsUpdated="$(checkWorkshopItemUpdates "${zomboidWorkshopAcfFile}")"
  if [[ -n "${workshopItemsUpdated}" ]]; then
    echo "${workshopItemsUpdated}"
    if [[ -n "${broadcastMsg}" ]]; then
      broadcastMsg+="<LINE>.${workshopItemsUpdated}"
    else
      broadcastMsg="${workshopItemsUpdated}"
    fi
  fi

  if [[ -n "${broadcastMsg}" ]]; then
    pz_restart_graceful "${broadcastMsg}"
  fi
}

function checkProjectZomboidBuildId() {
  local zomboidGameAcfFile="${1}"

  if [[ ! -f "${zomboidGameAcfFile}" ]]; then
    return
  fi

  local zomboidGameCacheJson
  zomboidGameCacheJson="$(parseAcfToJson "${zomboidGameAcfFile}")"

  local localBuildId localLastUpdated
  read -r -d '' localBuildId localLastUpdated \
    < <(jq -r '[.AppState.buildid, .AppState.LastUpdated] | map("__"+.) | join("\n")' <<< "${zomboidGameCacheJson}"; printf '\0';)
  localBuildId="${localBuildId#__}"
  localLastUpdated="${localLastUpdated#__}"

  if [[ -z "${localBuildId}" ]]; then
    # possibly failed to parse acf ?
    return
  fi

  local steamAppInfoJson
  steamAppInfoJson="$(steamCmdPrintAppInfoJson "${PZ_SERVER_STEAM_APPID}")"
  local jqSteamAppQuery="[.\"${PZ_SERVER_STEAM_APPID}\".depots.branches.public.buildid, .\"${PZ_SERVER_STEAM_APPID}\".depots.branches.public.timeupdated]"' | map("__"+.) | join("\n")'
  local actualBuildId actualTimeUpdated
  read -r -d '' actualBuildId actualTimeUpdated \
    < <(jq -r "${jqSteamAppQuery}" <<< "${steamAppInfoJson}"; printf '\0';)
  actualBuildId="${actualBuildId#__}"
  actualTimeUpdated="${actualTimeUpdated#__}"

  if [[ -z "${actualBuildId}" ]]; then
    # possibly failed steamcmd, or failed to parse output
    return
  fi

  if [[ "${localBuildId}" == "${actualBuildId}" ]]; then
    return
  fi

  (
    umask 0077
    touch "${PZ_RUN_STEAMCMD_UPDATE}"
  )
  echo "Project Zomboid BuildId Updated: ${actualBuildId}"
}

function steamCmdPrintAppInfoJson() {
  local steamAppId="${1}"

  local steamCmdOutput
  local -a STEAMCMD_PARAMS=(
    +login anonymous
    +app_info_update 1
    +app_info_print "${steamAppId}"
    +quit
  )
  steamCmdOutput="$("${STEAMCMD_BIN}" "${STEAMCMD_PARAMS[@]}")"

  local tmpAcfFile
  tmpAcfFile="$(mktemp)"

  # unfortunately no nice way to parse steamcmd
  # we look for the appId with quotes around it, which should be first line of acf output
  sed -En '/^"'"${steamAppId}"'"/,$ p' <<< "${steamCmdOutput}" | \
    tee "${tmpAcfFile}" >/dev/null

  parseAcfToJson "${tmpAcfFile}"

  # cleanup tmp file
  rm -f "${tmpAcfFile}"
}

function checkWorkshopItemUpdates() {
  local zomboidWorkshopAcfFile="${1}"

  if [[ ! -f "${zomboidWorkshopAcfFile}" ]]; then
    # if there are no workshop items this file will not exist
    return
  fi

  local zomboidWorkshopCacheJson
  zomboidWorkshopCacheJson="$(parseAcfToJson "${zomboidWorkshopAcfFile}")"

  local -a workshopItemIdsArr
  mapfile -t workshopItemIdsArr <<< "$(jq -r '(.AppWorkshop.WorkshopItemsInstalled | keys // empty)[]' <<< "${zomboidWorkshopCacheJson}")"
  if [[ ${#workshopItemIdsArr[@]} -eq 0 ]]; then
    # no workshop items installed
    return
  fi

  local workshopItemId postContentParams="itemcount=${#workshopItemIdsArr[@]}&format=json"
  local -i count=0
  for workshopItemId in "${workshopItemIdsArr[@]}"; do
    postContentParams+="&publishedfileids%5B$((count++))%5D=${workshopItemId}"
  done

  local steamworksResponseJson
  steamworksResponseJson="$(wget -nv -O- 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/' --post-data "${postContentParams}")"

  local workshopActualUpdateTime workshopLocalUpdateTime workshopItemName
  local -A newWorkshopItems=()
  for workshopItemId in "${workshopItemIdsArr[@]}"; do
    workshopActualUpdateTime="$(jq -r '.response.publishedfiledetails[] | select(.publishedfileid=="'"${workshopItemId}"'") | .time_updated' <<< "${steamworksResponseJson}")"
    workshopLocalUpdateTime="$(jq -r ".AppWorkshop.WorkshopItemsInstalled.\"${workshopItemId}\".timeupdated" <<< "${zomboidWorkshopCacheJson}")"
    if [[ "${workshopActualUpdateTime}" != "${workshopLocalUpdateTime}" ]]; then
      workshopItemName="$(jq -r '.response.publishedfiledetails[] | select(.publishedfileid=="'"${workshopItemId}"'") | .title' <<< "${steamworksResponseJson}")"
      newWorkshopItems+=(["${workshopItemId}"]="${workshopItemName}")
    fi
  done

  if [[ ${#newWorkshopItems[@]} -eq 0 ]]; then
    return
  fi

  local message="The following workshop items have been updated: "
  local appendComma=0
  for workshopItemId in "${!newWorkshopItems[@]}"; do
    if [[ ${appendComma} -eq 1 ]]; then
      message+=', '
    fi
    message+="${newWorkshopItems[${workshopItemId}]} (${workshopItemId})"
    appendComma=1
  done
  echo "${message}"
}

main "$@"
