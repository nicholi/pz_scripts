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
declare -r PZ_WORKSHOPSH_GZ_BASE64='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'
declare -r PZ_RESTARTSH_GZ_BASE64='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'

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
Cmnd_Alias PZ_CREATE_BAK = /usr/bin/tar cf - --exclude=./Zomboid/Logs -C '"${STEAM_DATA_DIR}"' ./Zomboid

pz_user ALL=(root) NOPASSWD: PZ_STOP, PZ_START, PZ_RESTART, PZ_SCHED_RESTART, PZ_CREATE_BAK
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
