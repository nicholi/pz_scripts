#!/bin/bash

set -o nounset -o errexit -o pipefail
shopt -s inherit_errexit

declare -r STEAMCMD_BIN=/opt/steamcmd/steamcmd.sh
declare -r STEAMCMD_USER=steam

declare -r STEAM_GAMES_DIR=/opt/steamgames
declare -r STEAM_DATA_DIR=/opt/steamdata
declare -r STEAM_DATA_BACKUP_DIR="${STEAM_DATA_DIR}/Backups"
declare -r PZ_HOME="${STEAM_GAMES_DIR}/ProjectZomboid"
declare -r PZ_DATA="${STEAM_DATA_DIR}/Zomboid"
declare -r PZ_USER=pz_user
declare -r PZ_SERVER_STEAM_APPID=380870
declare -r PZ_NODE_PATH=/opt/pz_node_modules

declare -r RCON_BASE=/opt
declare -r RCON_ETC_DIR=/etc/rcon
declare -r RCON_LOG_DIR=/var/log/rcon

declare -r PZ_BASHRC_GZ_BASE64='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'
declare -r PZ_WORKSHOPSH_GZ_BASE64='H4sICGYzC2ICA3B6X3dvcmtzaG9wX3VwZGF0ZS5zaAC9Vttu20YQfedXjGknouCQtAOkCGITiOpL46C2hchFgCqCsCKH0jokl95d2rVd/XtnedGFktsUBfpGzs6cOXvmQu7u+BOe+ROmZpalUIMrIBNFVj+ilPgHLx9znmPMeGKpmcjJooBnM5Rcj2sny9qFiMcxSsw0xFKkoFDeowSW5zyyIgwTJhFcCf3fx4Obs97luNfvX5wGhwfvfzo4MPFqhkkSzjD8DkoUMsTA8/Mnz9CToVWZwC+U9BMRssRHHa6cW3GRhZqLDFLGM6cLzxZA6QhPIp0IHvXC+JwnGNh7z8Th0/Xl2dxXGllKFJX/IOR3czuf3prncem5wnbusTC2CZjHMBzCDrgxENx6grkNo9ER6Blm5AmwS6JCAwlcY2rkU5olCUbANNBD6ShRF9LExNyyTBxPc1Iy1wUhRHirjJigqRxMKgSiQjj0eqvo1iyLAMOZgAkjAcmqdCQKvRCBvPsmTA5CyXMddLR8JI1CQUyg1xxCQCzuCi7RsTuVUFfXp2fjfu/m09w3LMapiIoEVSWdS7BvTX7y7h7VaOdqFSZWy5N1ocjrXHkSWWTeBo9Z6NB9Q1TKY3J6P3w7egN2oWP3/RKBGolIRBS64OxVNmcdvI4QCXqJmDqfB9dXntKSZ1MePzo1TJe85hAyHc7AoVbu1oqYKHoV0hgpjCQlz4acaXjn0IRanXaTnTDq4M8kCB20TdR5jpEQ3K1Nc3x8bOytQs3trm0tsrhs0UkX1EgXkepJSafUw7FR1NVbzmtk5/bOzF/H8Xp5/rX28r6uuKuLRVv+Cd/xUYHvA1IDPnaHo05DsH2tkmEzEnvPu5sEhh9Hc3DxDg7+xWRsG4lKhPUEkAulT0SmafOQcCxVgW2gQtpkOniRz+tYyJTpoGzepb4cqrgDk1PIdi6eGQW2I9pHEImS9Qaj/cB+nReThNOOi0yheKRevft5z3HKbPv73e6rd6dBG3luiEUiw+Xdy6krvb6gyqlVm2bbfmBa7mFq9nl2D+61C52Z1rn64NOa414Zk4sH2tqRF4rUvxgYyxdMhcaBFpJN0f8Fdb+hbjr1FDV9CZR/f+h3wHXNXd2IaWaE2bj4evc2t+uFumDJbzmF4Q1PcXHwq3HbYjdyXLEUl3XqQYYPa70bON3/UrOXuAXLwaFVVSnrrdUyqgQZjmhoFCYYasdrFTsIym3ari7tTIrxNKUZF2XGaDFl2+tZzxq8pNiSrf0DU+592yT1zS751HTsfxj6ZuxXcNoC0mbbCVYdWpTbn0vYqPr/UgKd4I9qDxu9tx84wy3go6BlNLchmBKFNtpyuBfLs41crc6pbq/OagwmUrDoUk0D+2aG1PtJIh7oC9feqTN2jzBBzKAu6wewV1DorwKz6ESkKSv33t9M0c42fsshWl5kBbNa/YftKsOC/X7QeQOd2lzKsn5KeTfSbohNMjkbxkXBVq94WNpK5c1D+dNEKZp88yomfxpTr2km9XgqWYhxkWx4Ede5ZZn/TTr6aFt/Ab6Eu6xRCwAA'
declare -r PZ_RESTARTSH_GZ_BASE64='H4sICEyICGICA3B6X3Jlc3RhcnRfZ3JhY2VmdWwuc2gAxVZtc9pGEP6uX7GVnQBxQOBOOxNqPCWN4noG4wyQdjq2x3NIC9xY3Km6k/FL+O/dOwmQeGn6rR+MJd3e7rPPPbt7Rz94Yy68MVMzx1GooS5ByFTkj5gk+MTtY8xjnDAeOWomY/qigIsZJlzf50aOE2IQsQShnnD45H/ufu2N7gf+cNQdjO6vLvvDzo/Nkk2359OK/4c/+Musd35ynCNQM4yiYIbBAyiZJgF2Gl780jAIk8DJPoGXqsSLZMAiD3VQWHcmqQg0lwLmjItqDV4dAGsICSrNEn3Fheq4x6+tdv34dR/K5dLd3jNApqQwu07bdVqm9SNgSqWUyCOLUgSugAliROMUE1qOE3qeQP2xGBYqb5qNSQXIT+GrDccncHMD5e9QjxCacHf3C+gZCrIyYTNqJjKBF0ykJ3DKNH9EggMLYs5abaW6N0sTdcKddap1TtsMaVxMR3yOnTIYslvMOAHKYRYsCehU50BDmQMoeapa0F8i9ozJb6Qu3RXhx0SyMGBKZ3QU/bkFhjLql25tr18VIcbkbIBhGuDH5wO+toSWeQulQJN+HshAYsFDGjvLgor+DXhJXXvoay3/g47Wu+NNEKOfzRulOUVdwFAr6KVgR8eAf+/qRfGpoAhaAp/PMeRMY/RMVZbqUC4yIwxmEpo5wTpNRCaNFbjxKuErNe24Q39APEKuJbjs78qBKP468ocbXdfFnhMtAy0GOem4jbPeZd8/H/jd4XW/DTubVwjjl3u70/gvuiD3516Ij55IowhOz9+2nDzPXYWUDrxMdbmBBFJka2qAKpbUJIvffkcWYrJ1jnv20PFXCXZmp2pu2SrzYmxm9ETMteDs7Myi3nVFQnZtL+pfj/y2ITt+IckyMUXTj55BToBrBTLVcaqNBgI5nzMRKiKeWtaCEznuOEH24G6JjgAopPg+VJTXeJejpf1CYKBp5bZavWnWP9yd1G5rjXfebcvjlT1Qs3wsUIt0gRWKOWcP1DM1qDmd6Xtq9AZ7Qr3zCcyMUVBVbI6g8UkDm2hDayIDVIoOrUY+bPM1BjSB6IX+coAbyb0YIMXycOHbtwPgoNPZtS7JM5POn91B/7J/0S5AJSaI1hA1sZKDIJLIQwNWp2Tlu+/woHX+9jQvU4HkSUnKScUYcJLb0XugDmUni4KplKH5T4DIlFhpf9ng+vnDTu0ebBHrTl1oEWaYRHI6JXIhTpNYKpKPnWAmN6WJo8RGTpXRAF0AFsJuIMi8wE8dwR2OLns96F1fXPifqDm0b8VxVRNPpgecnH5HyytCsgRW5Vo6llKxbrfuvFzXTaHyuef7sP6pZGtKy5ie7OyAlso+BlQEGu/H2QjI7ch3Kd72uNmeAEFKVyHTsYu9306GzL6PzECm9dOls8+gcGy5rwNdvdjLx+ZWdqiPY7TrkKZ4a0cD3EwJTqXGTKq5kwxVp2VfV9k1D7glaZneWkp1WY6zNStDe1eCzRvNumruEN5s01bL7gCbq1K+iUKLnYtSAX3RNOMpUrjPqIzcWtghA7BGVe+szCyatSfT2GDB8oqxyiK5kuxXpLX+x/yr1bUt1KGV+9nLgjEtBS1s+A4XdjlL3d2wuZy7q1LeaMUUlQFEhr+6zj/1gJ82hAwAAA=='

declare cleanGame=0
declare cleanData=0

function main() {
  if [[ $EUID -ne 0 ]]; then
    echo 'ERROR: script must be run with root privileges.'
    exit 1
  fi

  local pzServerName
  if [[ -z "${1:-}" || "${1}" == '--'* ]]; then
    echo 'ERROR: first parameter must supply name of server'
    exit 2
  fi
  pzServerName="${1}"

  shift
  local nextInput
  nextInput="${1:-}"
  while [[ -n "${nextInput}" ]]; do
    case "${nextInput}" in
      '--clean-game')
        cleanGame=1
        ;;
      '--clean-data')
        cleanData=1
        ;;
      '--clean-all')
        cleanGame=1
        cleanData=1
        ;;
    esac
    shift
    nextInput="${1:-}"
  done

  if [[ ${cleanGame} -eq 1 ]]; then
    rm -Rf "${PZ_HOME}"
  fi
  if [[ ${cleanData} -eq 1 ]]; then
    rm -Rf "${PZ_DATA}"
  fi

  local -a packages=(
    sqlite3 acl p7zip-full jq crudini
  )
  # node/npm could be installed from alt locations
  # we do not want to mix/match if not necessary
  which node >/dev/null || packages+=(nodejs)
  which npm  >/dev/null || packages+=(npm)
  apt-get update -q=2 -y
  apt-get install -y "${packages[@]}"

  # create user if does not exist
  getent passwd "${PZ_USER}" >/dev/null || adduser --system --group --home "${PZ_HOME}" "${PZ_USER}"

  mkdir -p "${PZ_HOME}"
  # assure steam and pz_user always have full permissions to game dir
  setfacl -m "d:u:${STEAMCMD_USER}:rwX" -m "u:${STEAMCMD_USER}:rwx" \
          -m "d:u:${PZ_USER}:rwX" -m "u:${PZ_USER}:rwx" \
          "${PZ_HOME}"

  mkdir -p "${STEAM_DATA_DIR}"
  (
    umask 0027

    mkdir -p "${PZ_DATA}"
    chown -R "${PZ_USER}:${PZ_USER}" "${PZ_DATA}"
    # always assure pz_user has access to data dir
    # give adm read access
    # block world permissions
    setfacl -m "d:u:${PZ_USER}:rwX" -m "u:${PZ_USER}:rwx" \
            -m 'd:g:adm:rX' -m 'g:adm:rx' \
            -m 'd:o::-' -m 'o::-' \
            "${PZ_DATA}"

    mkdir -p "${STEAM_DATA_BACKUP_DIR}"
    chgrp 'adm' "${STEAM_DATA_BACKUP_DIR}"
    setfacl -m "d:u:${PZ_USER}:rwX" -m "u:${PZ_USER}:rwx" \
            -m "d:g:adm:rX" -m "g:adm:rx" \
            -m 'd:o::-' -m 'o::-' \
            "${STEAM_DATA_BACKUP_DIR}"

    if [[ ! -f "${PZ_DATA}/db/${pzServerName}.db" ]]; then
      mkdir -p "${PZ_DATA}/db"
      touch "${PZ_DATA}/db/${pzServerName}.db"
      chown -R "${PZ_USER}:${PZ_USER}" "${PZ_DATA}/db"
    fi
    if [[ ! -f "${PZ_DATA}/Server/${pzServerName}.ini" ]]; then
      mkdir -p "${PZ_DATA}/Server"
      touch "${PZ_DATA}/Server/${pzServerName}.ini"
      chown -R "${PZ_USER}:${PZ_USER}" "${PZ_DATA}/Server"
    fi
  )

  local rconPassword=''
  # get password if already set, no simple way to do this
  if crudini --get "${PZ_DATA}/Server/${pzServerName}.ini" '' 'RCONPassword' >/dev/null 2>&1 ; then
    rconPassword="$(crudini --get "${PZ_DATA}/Server/${pzServerName}.ini" '' 'RCONPassword')"
  fi
  # if not request password from user
  if [[ -z "${rconPassword}" ]]; then
    rconPassword="$(readSecurePassword 'Create RCON password')"
  fi
  setOrUpdatePzSetting "${PZ_DATA}/Server/${pzServerName}.ini" 'Open' 'false'
  setOrUpdatePzSetting "${PZ_DATA}/Server/${pzServerName}.ini" 'RCONPassword' "${rconPassword}" 1

  # standard branch should be 'public'
  local -a STEAMCMD_PARAMS=(
    +force_install_dir "${PZ_HOME}"
    +login anonymous
    +app_update "${PZ_SERVER_STEAM_APPID}" validate
    +quit
  )
  sudo -u "${STEAMCMD_USER}" -s /bin/bash "${STEAMCMD_BIN}" "${STEAMCMD_PARAMS[@]}"

  local pzService=pz-server.service
  local pzExecLine="'${PZ_HOME}/start-server.sh' -cachedir='${PZ_DATA}' -servername '${pzServerName}'"
  local ipAddress=''
  # might not want to force ip parameter, as using localhost for RCON is quite useful
  # unless you can specify multiple -ip parameters? little to no documentation
  # NOTE: further minor issue related to pz-server itself. if the server contains multiple
  #  interfaces with addresses listening this apparently confuses pz-server (any generic DigitalOcean server).
  #  and with no ability to control what interface/address to listen on
  #  (using the -ip parameter DOES NOT help) issues may arise connected to server.
  #  it is *NOT* a port issue, do not listen to redundant morans online with no real knowledge
  #ipAddress="$(curl -s ifconfig.me)"
  if [[ -n "${ipAddress}" ]]; then
    pzExecLine+=" -ip '${ipAddress}'"
  fi
  local pzSystemdService="[Unit]
Description=Project Zomboid Server
Documentation=https://pzwiki.net/wiki/Dedicated_Server
Wants=network-online.target local-fs.target
After=network-online.target local-fs.target

[Service]
Type=simple
KillSignal=SIGINT
TimeoutStopSec=180
Restart=on-failure
User=${PZ_USER}
Group=${PZ_USER}
ExecStart=${pzExecLine}
WorkingDirectory=${PZ_HOME}

[Install]
WantedBy=multi-user.target
"
  tee "/etc/systemd/system/${pzService}" >/dev/null <<< "${pzSystemdService}"
  systemctl daemon-reload
  systemctl enable "${pzService}"
  echo -e "\nTo start server run: sudo systemctl start pz-server.service\n"

  insertAdminWhitelist "${PZ_DATA}/db/${pzServerName}.db" "${pzServerName}"

  installRcon "${PZ_USER}" "${rconPassword}"
  installPzFunctions
  installAdminScripts "${PZ_USER}"
}

### crudini will unfortunately add whitespace on NEW settings
### using --existing to detect and manually append new entry otherwise
function setOrUpdatePzSetting() {
  local settingsFile="$1"
  local settingName="$2"
  local settingValue="$3"
  local useMerge="${4:-0}"

  if [[ ${useMerge} -ne 1 ]]; then
    crudini --set --existing "${settingsFile}" '' "${settingName}" "${settingValue}" 2>/dev/null || \
      tee -a "${settingsFile}" <<< "${settingName}=${settingValue}" >/dev/null
  else
    # for sensitive values, merge via stdin input
    # must first detect if settingName exists (because of whitespace insertion issue)
    if crudini --get "${settingsFile}" '' "${settingName}" >/dev/null 2>&1 ; then
      crudini --merge --existing "${settingsFile}" '' <<< "${settingName}=${settingValue}"
    else
      tee -a "${settingsFile}" <<< "${settingName}=${settingValue}" >/dev/null
    fi
  fi
}

function readSecurePassword() {
  local inputPrompt="${1:-}"
  echo 1>&2
  if [[ -n "${inputPrompt}" ]]; then
    echo "${inputPrompt}" 1>&2
  fi
  local password confirmPassword=''
  IFS= read -s -r -p $'  Enter password:\n' password 1>&2
  echo 'To reset first password leave confirm password blank' 1>&2
  while [[ "${password}" != "${confirmPassword}" ]]; do
    IFS= read -s -r -p $'Confirm password:\n' confirmPassword 1>&2
    # triggering restart of password entry
    if [[ -z "${confirmPassword}" ]]; then
      IFS= read -s -r -p $'  Enter password:\n' password 1>&2
      echo 'To reset first password leave confirm password blank' 1>&2
      IFS= read -s -r -p $'Confirm password:\n' confirmPassword 1>&2
    fi
  done
  echo 1>&2
  echo "${password}"
}

function insertAdminWhitelist() {
  local databaseFile="${1}"
  local serverName="${2}"

  # create base whitelist table and indexes (same as pzserver) and query for admin user
  # this is one of the more brittle parts of the pz installation, if any of the schema is changed
  # we fail fast. however inserting admin passwords natively into db (and hashed) is far better
  # than the alternative of passing the admin password as a commandline argument to server
  local adminUserIdResp sqlQuery
  sqlQuery="CREATE TABLE IF NOT EXISTS [whitelist] (
  [id] INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  [world] TEXT DEFAULT '${serverName}' NULL,
  [username] TEXT NULL,
  [password] TEXT NULL,
  [admin] BOOLEAN DEFAULT false NULL,
  [moderator] BOOLEAN DEFAULT false NULL,
  [banned] BOOLEAN DEFAULT false NULL,
  [lastConnection] TEXT NULL,
  [encryptedPwd] BOOLEAN NULL DEFAULT false,
  [pwdEncryptType] INTEGER NULL DEFAULT 1,
  [steamid] TEXT NULL,
  [ownerid] TEXT NULL,
  [accesslevel] TEXT NULL,
  [transactionID] INTEGER NULL,
  [displayName] TEXT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS [id] ON [whitelist]([id] ASC);
CREATE UNIQUE INDEX IF NOT EXISTS [username] ON [whitelist]([username] ASC);
SELECT 'SENTINEL', [id] FROM [whitelist] WHERE [username] = 'admin';
"
  adminUserIdResp="$(sqlite3 "${databaseFile}" <<< "${sqlQuery}")"
  if [[ -n "${adminUserIdResp}" ]]; then
    # if response is not null and does not start with our SENTINEL value
    # it means this is an error of some type
    if [[ "${adminUserIdResp}" != 'SENTINEL|'* ]]; then
      echo "${adminUserIdResp}" 1>&2
      return 3
    fi
    # else admin already inserted
    return
  fi

  local adminPassword
  adminPassword="$(readSecurePassword 'Create password for admin account')"
  local bcryptAdminPassword
  bcryptAdminPassword="$(hashPzPassword "${adminPassword}")"

  # insert admin user, let defaults handle other fields
  sqlQuery="INSERT INTO [whitelist]
  ([username],[password],[encryptedPwd],[pwdEncryptType],[accesslevel])
  VALUES('admin','${bcryptAdminPassword}','true',2,'admin');
"
  sqlite3 "${databaseFile}" <<< "${sqlQuery}"
}

function hashPzPassword() {
  local password="${1}"

  # holding any common nodejs modules under this path
  mkdir -p "${PZ_NODE_PATH}"
  npm install --prefix "${PZ_NODE_PATH}" bcryptjs 1>&2

  # we also want to assure to encode the password as a safe to pass javascript string
  local jsPassword
  jsPassword="$(jq -n '$password' --arg password "${password}")"

  # class PZcrypt logic is rather obtuse
  # first they hash password with MD5, and then feed that into bcrypt with a static salt
  # shellcheck disable=SC2016
  local hashPasswordScript='try {
  const Crypto = require("crypto");
  const Bcrypt = require("'"${PZ_NODE_PATH}/node_modules/bcryptjs"'");
  const md5Hashed = Crypto.createHash("md5").update('"${jsPassword}"').digest("hex");
  const hashedPassword = Bcrypt.hashSync(md5Hashed, "$2a$12$O/BFHoDFPrfFaNPAACmWpu");
  console.log(hashedPassword);
} catch (err) {
  console.error(err.stack);
  process.exit(1);
}
'
  local adminHashedPassword
  adminHashedPassword="$(node - <<< "${hashPasswordScript}")"
  echo "${adminHashedPassword}"
}

function installRcon() {
  local pzUser="${1}"
  # bashsupport disable=BP3001
  # shellcheck disable=SC2034
  local rconPassword="${2}"

  local rconGithubRepo='gorcon/rcon-cli'
  local rconReleaseUrl
  rconReleaseUrl="$(wget -nv -O- "https://api.github.com/repos/${rconGithubRepo}/releases/latest" | \
    jq -r '.assets[] | select(.name | endswith("amd64_linux.tar.gz")) | .browser_download_url')"
  if [[ -z "${rconReleaseUrl}" ]]; then
    # but don't completely error out
    echo "WARNING: Failed to detect latest github release for ${rconGithubRepo}"
    return
  fi

  # to manipulate the yaml file
  snap install yq

  local rconTarball
  rconTarball="$(mktemp)"
  wget -nv -O "${rconTarball}" "${rconReleaseUrl}"

  local rconVersionDir
  rconVersionDir="$(tar tvf "${rconTarball}" --exclude='*/*' | awk '{print $(NF)}' | sed -E 's%^\.?/%%;s%/$%%')"

  tar xzf "${rconTarball}" --no-same-owner --no-same-permissions -C "${RCON_BASE}"
  rm -f "${rconTarball}"
  ln -snf "${RCON_BASE}/${rconVersionDir}/rcon" /usr/local/bin

  getent group rcon >/dev/null || addgroup rcon
  usermod -a -G rcon "${pzUser}"

  (
    umask 0027
    mkdir -p "${RCON_ETC_DIR}"
    chgrp rcon "${RCON_ETC_DIR}"

    if [[ ! -f "${RCON_ETC_DIR}/rcon.yaml" ]]; then
      cp -f "${RCON_BASE}/${rconVersionDir}/rcon.yaml" "${RCON_ETC_DIR}"
    fi

    local yamlFile
    # because yq is a snap app, it has curious permissions access to disk
    yamlFile="$(cat "${RCON_ETC_DIR}/rcon.yaml")"

    export rconPassword
    # set default address, our password, and logging location
    yq '
      .default.address = "127.0.0.1:27015" |
      .default.password = strenv(rconPassword) |
      .default.log = "'"${RCON_LOG_DIR}/rcon-default.log"'"
    ' <<< "${yamlFile}" | tee "${RCON_ETC_DIR}/rcon.yaml" >/dev/null
    chgrp rcon "${RCON_ETC_DIR}/rcon.yaml"
    chmod g-w,o-rwx "${RCON_ETC_DIR}/rcon.yaml"

    umask 0007
    mkdir -p "${RCON_LOG_DIR}"
    setfacl -m 'd:g:rcon:rwX' -m 'g:rcon:rwx' \
            -m 'd:g:adm:rX' -m 'g:adm:rx' \
            -m 'd:o::-' -m 'o::-' \
            "${RCON_LOG_DIR}"
  )

  tee /etc/logrotate.d/rcon >/dev/null <<< "${RCON_LOG_DIR}/*.log {
        daily
        missingok
        rotate 30
        compress
        delaycompress
        notifempty
        copytruncate
        create 640 root rcon
        sharedscripts
        postrotate
        endscript
}
"
}

### all functions entirely depend on rcon being installed
### and config setup in ${RCON_ETC_DIR}/rcon.yaml
function installPzFunctions() {
  local baseDir=/usr/local/etc
  local pzBashRc="${baseDir}/pz.bashrc"
  mkdir -p "${baseDir}"
  base64 --decode <<< "${PZ_BASHRC_GZ_BASE64}" | gunzip -c | tee "${pzBashRc}" >/dev/null

  # and attach for interactive bash shells
  local includeHeader='# Project Zomboid Admin Functions'
  if grep -q -F "${includeHeader}" /etc/bash.bashrc ; then
    # already installed
    return
  fi

  tee /etc/bash.bashrc >/dev/null <<< "${includeHeader}
source ${pzBashRc}
"
}

### as per PzFunctions, these scripts highly depend on rcon being installed and configured
function installAdminScripts() {
  local pzUser="$1"

  local BIN_DIR=/usr/local/bin

  # shellcheck disable=SC2016
  local pzPurgeBackupsSh='#!/bin/bash

declare -r STEAM_DATA_BACKUP_DIR='"${STEAM_DATA_BACKUP_DIR}"'
declare -r MAX_DAYS_BACKUP=14

find "${STEAM_DATA_BACKUP_DIR}" -maxdepth 1 -type f -mtime "+${MAX_DAYS_BACKUP}" -delete
'
  tee /etc/cron.daily/pz-purge-backups <<< "${pzPurgeBackupsSh}" >/dev/null
  chmod +x /etc/cron.daily/pz-purge-backups

  # allow pzUser to restart systemd unit and run scheduled restart without password
  local pzSudoers='Cmnd_Alias PZ_STOP = /bin/systemctl stop pz-server.service
Cmnd_Alias PZ_START = /bin/systemctl start pz-server.service
Cmnd_Alias PZ_RESTART = /bin/systemctl restart pz-server.service
Cmnd_Alias PZ_SCHED_RESTART = /bin/systemctl start pz-scheduled-restart.service

pz_user ALL=(root) NOPASSWD: PZ_STOP, PZ_START, PZ_RESTART, PZ_SCHED_RESTART
'
  (
    umask 0227
    tee /etc/sudoers.d/pz_server <<< "${pzSudoers}" >/dev/null
  )

  # graceful restart script
  local restartSh="${BIN_DIR}/pz_restart_graceful.sh"
  base64 --decode <<< "${PZ_RESTARTSH_GZ_BASE64}" | gunzip -c | tee "${restartSh}" >/dev/null
  chmod +x "${restartSh}"

  local restartTimer=pz-scheduled-restart.timer
  tee "/etc/systemd/system/${restartTimer}" >/dev/null <<< '[Unit]
Description=Project Zomboid Scheduled Restart Timer

[Timer]
# once a day, everyday at noon PST
OnCalendar=12:00:00 America/Los_Angeles

[Install]
WantedBy=timers.target
'
  tee /etc/systemd/system/pz-scheduled-restart.service >/dev/null <<< "[Unit]
Description=Project Zomboid Scheduled Restart

[Service]
Type=oneshot
User=${pzUser}
Group=${pzUser}
ExecStart=${restartSh}
"

  # half hour check for workshop item updates
  local workshopSh="${BIN_DIR}/pz_workshop_update.sh"
  base64 --decode <<< "${PZ_WORKSHOPSH_GZ_BASE64}" | gunzip -c | tee "${workshopSh}" >/dev/null
  chmod +x "${workshopSh}"

  local workshopTimer=pz-workshop-update.timer
  tee "/etc/systemd/system/${workshopTimer}" >/dev/null <<< '[Unit]
Description=Project Zomboid Workshop Update Timer

[Timer]
# every half hour
OnCalendar=*:00,30:00 UTC

[Install]
WantedBy=timers.target
'
  tee /etc/systemd/system/pz-workshop-update.service >/dev/null <<< "[Unit]
Description=Project Zomboid Workshop Update

[Service]
Type=oneshot
User=${pzUser}
Group=${pzUser}
ExecStart=${workshopSh}
"
  # extra dependency needed by workshop_update.sh
  mkdir -p "${PZ_NODE_PATH}"
  npm install --prefix "${PZ_NODE_PATH}" steam-acf2json

  # start timers
  systemctl daemon-reload
  systemctl enable "${restartTimer}"
  systemctl start  "${restartTimer}"
  systemctl enable "${workshopTimer}"
  systemctl start  "${workshopTimer}"
}

main "$@"
