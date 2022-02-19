#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

# different from server appid
declare -r PZ_STEAM_APPID=108600
# parseable by date
declare SERVICE_RUNNING_OLDER_THAN='1 min ago'

# shellcheck source=./pz.bashrc
source /usr/local/etc/pz.bashrc
if [[ -f /usr/local/etc/pz.bashrc.local ]]; then
  # use this file to specify any overrides
  source /usr/local/etc/pz.bashrc.local
fi

function main() {
  local zomboidAcfFile="${PZ_HOME}/steamapps/workshop/appworkshop_${PZ_STEAM_APPID}.acf"
  if [[ ! -f "${zomboidAcfFile}" ]]; then
    # no workshop items installed at all
    return
  fi

  local jqParseRawInputQuery serviceJson activeState subState activeEnterTimestamp
  jqParseRawInputQuery='split("\n") | map(select(. != "") | split("=") | {"key": .[0], "value": (.[1:] | join("="))}) | from_entries'
  serviceJson="$(systemctl show -p "ActiveState" -p "SubState" -p "ActiveEnterTimestamp" pz-server.service | \
    jq -c --slurp --raw-input "${jqParseRawInputQuery}")"
  read -r -d '' activeState subState activeEnterTimestamp \
    < <(jq -r '[.ActiveState, .SubState, .ActiveEnterTimestamp] | map("__"+.) | join("\n")' <<< "${serviceJson}"; printf '\0';)
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
  if [[ "$(date --date "${ActiveEnterTimestamp}" '+%s')" -ge "$(date --date "${SERVICE_RUNNING_OLDER_THAN}" '+%s')" ]]; then
    echo "Service only recently started. ActiveEnterTimestamp=${activeEnterTimestamp}. CurrentTimestamp=$(date)"
    return
  fi

  # impromptu nodejs app to parse acf into json and echo back to stdout
  local acfParserScript='try {
  const AcfParser = require("'"${PZ_NODE_PATH}/node_modules/steam-acf2json"'");
  const Fs = require("fs");
  const zomboidAcfFile = Fs.readFileSync(process.argv[2], "utf-8");
  const decoded = AcfParser.decode(zomboidAcfFile);
  console.log(JSON.stringify(decoded));
} catch (err) {
  console.error(err.stack);
  process.exit(1);
}
'
  local zomboidCacheJson
  zomboidCacheJson="$(node - "${zomboidAcfFile}" <<< "${acfParserScript}")"

  local -a workshopItemIdsArr
  mapfile -t workshopItemIdsArr <<< "$(jq -r '(.AppWorkshop.WorkshopItemsInstalled | keys // empty)[]' <<< "${zomboidCacheJson}")"
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
    workshopLocalUpdateTime="$(jq -r ".AppWorkshop.WorkshopItemsInstalled.\"${workshopItemId}\".timeupdated" <<< "${zomboidCacheJson}")"
    if [[ "${workshopActualUpdateTime}" != "${workshopLocalUpdateTime}" ]]; then
      workshopItemName="$(jq -r '.response.publishedfiledetails[] | select(.publishedfileid=="'"${workshopItemId}"'") | .title' <<< "${steamworksResponseJson}")"
      newWorkshopItems+=(["${workshopItemId}"]="${workshopItemName}")
    fi
  done

  if [[ ${#newWorkshopItems[@]} -gt 0 ]]; then
    local broadMsg="The following workshop items have been updated: "
    local appendComma=0
    for workshopItemId in "${!newWorkshopItems[@]}"; do
      if [[ ${appendComma} -eq 1 ]]; then
        broadMsg+=', '
      fi
      broadMsg+="${newWorkshopItems[${workshopItemId}]} (${workshopItemId})"
      appendComma=1
    done
    echo "${broadMsg}"
    pz_restart_graceful "${broadMsg}"
  fi
}

main "$@"
