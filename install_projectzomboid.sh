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
declare -r LOCAL_BIN_DIR=/usr/local/bin

declare -r RCON_BASE=/opt
declare -r RCON_ETC_DIR=/etc/rcon
declare -r RCON_LOG_DIR=/var/log/rcon

declare -r PZ_BASHRC_GZ_BASE64='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'
declare -r PZ_WORKSHOPSH_GZ_BASE64='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'
declare -r PZ_RESTARTSH_GZ_BASE64='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'
declare -r PZ_STARTUP_GZ_BASE64='H4sICEVyr2MCA3B6X3N0YXJ0dXBfdGVzdC5zaACNVNtO20AQffdXTA0qCcVJHAmhUlK1alP1AUHE5aWA0MYexyvs3dXumhAg/94Z26ShpFKVl/Vk5syZy5mtd/2pVP2pcHkQOPQQaVC6Uu0TrcUHWT+NNJgJWQQu14YsDqTK0Up/2zoFQYpJISxCZOH7+MfXy+OL2/Pj8XgyioeDIMgqlXipFZRCqk4XngKALcAHg4nHFLwGWymQZYmpFB6LBYjMowXnhfWV2QOnYS5sWRmQDhQm6JywC0JxBaKBcPvpVdZlGNQZMmmdhyTH5A5kBjYhCkZbzyh4jwq0QUWe0k3IeiydRyXVDMJ4eNAb0C8OIRweDOL9EJ6fa9oAmOQawskvOEd7TySNdj5qmR5SBz0UKyDKt6qyTtyp0bohxJ/fD2s4i76yCmL6WDasUw0CnCxNgXD27fQESi53htwnh8iVuCY1lbHKRaGFTkRRVzkpxAKtO0NnNA103fYTRcqs669vNG9PkRtiRuF2xzzeNn6uG772alDYJ6cXRCqGo6MjHsQGqGVYh2/ByenF+JD5m0eailAzdCDUAnQG0jvQlTeV5zITXZZC0WbkVOJcFgWEU4vijmHWmHN+R62NxrDj+r3dliyFK9U0/brTuRpEH28+dK+7vd3+ddyXOxuYNuXUPHkdMri6guiRndayLesl2BwIo9Fb75ubT1RBvWFcPW8gzvABWEuO/hGeRiuU29DY0ev5cPg8l0neNEMnSWUBJYFbmGIiKprxS8/sy9CbDqfQKStSQWVSklbDoNtCasv8/myT2vFgLInCkgQbnJRWqwdzbFTEYmXaHPUiJNbQHkxpcFQgOaaaYWZ0RQTMtF4jxKFt5lIs6IikMmFOgiTdngGshfQfOrtUK2Gt8CP4x/q9URt/ZJJn3RoGwXLtTP11D9qL1cgrJxq0d0/xMlzZuBVsGzaHRyUQ3fP+RPN93goOIRK8H+RIPpSLLyFZvoTBb8RnYA+IBQAA'

declare -r CHAR_DOUBLEQUOTE='"'

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
    # extended acl file permissions
    acl
    # sqlite client to insert admin into db
    sqlite3
    # backups using .tar.7z
    p7zip-full
    # manipulate json
    jq
    # manipulate ini
    crudini
    # only necessary to install yq
    snapd
  )
  # node/npm could be installed from alt locations
  # we do not want to mix/match if not necessary
  which node >/dev/null || packages+=(nodejs)
  which npm  >/dev/null || packages+=(npm)
  apt-get update -q=2 -y
  apt-get install -y "${packages[@]}"

  # to manipulate yaml
  snap install yq

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
            -m "d:g:adm:rX" -m "g:adm:rwx" \
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

  installPzStartupTest
  installPzSystemDUnit "${pzServerName}"

  insertAdminWhitelist "${PZ_DATA}/db/${pzServerName}.db" "${pzServerName}"

  installRcon "${PZ_USER}" "${rconPassword}"
  installPzFunctions
  installAdminScripts "${PZ_USER}"
}

function installPzStartupTest() {
  local startupSh="${LOCAL_BIN_DIR}/pz_startup_test.sh"
  base64 --decode <<< "${PZ_STARTUP_GZ_BASE64}" | gunzip -c | tee "${startupSh}" >/dev/null
  chmod +x "${startupSh}"
}

function installPzSystemDUnit() {
  local pzServerName="${1}"

  local pzService=pz-server.service
  local pzExecLine="'${PZ_HOME}/start-server.sh' -cachedir='${PZ_DATA}' -servername '${pzServerName}'"
  local pzExecStartPostLine="${LOCAL_BIN_DIR}/pz_startup_test.sh"
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
WorkingDirectory=${PZ_HOME}
ExecStart=${pzExecLine}
ExecStartPost=${pzExecStartPostLine}

[Install]
WantedBy=multi-user.target
"
  tee "/etc/systemd/system/${pzService}" >/dev/null <<< "${pzSystemdService}"
  systemctl daemon-reload
  systemctl enable "${pzService}"
  echo -e "\nTo start server run: sudo systemctl start pz-server.service\n"
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
  jsPassword="$(jq '.' <<< "${CHAR_DOUBLEQUOTE}${password}${CHAR_DOUBLEQUOTE}")"

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
Cmnd_Alias PZ_CREATE_BAK = /usr/bin/tar cf - --exclude=./Zomboid/Logs --exclude=./Zomboid/backups -C '"${STEAM_DATA_DIR}"' ./Zomboid
Cmnd_Alias PZ_STEAMCMD = '"${STEAMCMD_BIN}"' +force_install_dir '"${PZ_HOME}"' +login anonymous +app_update '"${PZ_SERVER_STEAM_APPID}"' validate +quit

pz_user ALL=(root) NOPASSWD: PZ_STOP, PZ_START, PZ_RESTART, PZ_SCHED_RESTART, PZ_CREATE_BAK
pz_user ALL=(steam) NOPASSWD: PZ_STEAMCMD
'
  (
    umask 0227
    tee /etc/sudoers.d/pz_server <<< "${pzSudoers}" >/dev/null
  )

  # graceful restart script
  local restartSh="${LOCAL_BIN_DIR}/pz_restart_graceful.sh"
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
  local workshopSh="${LOCAL_BIN_DIR}/pz_workshop_update.sh"
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
