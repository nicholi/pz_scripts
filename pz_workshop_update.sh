#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

# different from server appid
declare -r PZ_STEAM_APPID=108600

# shellcheck source=./pz.bashrc
source /usr/local/etc/pz.bashrc

function main() {
  local zomboidAcfFile="${PZ_HOME}/steamapps/workshop/appworkshop_${PZ_STEAM_APPID}.acf"
  if [[ ! -f "${zomboidAcfFile}" ]]; then
    # no workshop items installed at all
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
