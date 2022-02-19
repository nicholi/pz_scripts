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

declare -r PZ_WORKSHOPSH_GZ_BASE64='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'
declare -r PZ_RESTARTSH_GZ_BASE64='H4sICGScDWICA3B6X3Jlc3RhcnRfZ3JhY2VmdWwuc2gAxVZtc+I2EP7uX7F1cgdcDgzptDNHQ6Zcz5dmhpAb4NrpJJmMsBfQxEiuJYe8HP+9K9mAzUuv3/ohRJZWu88+erSrox+8MRfemKmZ4yjUUJcgZCryISYJPnE7jHmME8YjR81kTDMKuJhhwvV9buQ4IQYRSxDqCYdP/ufu197ofuAPR93B6P7qsj/s/Ngs2XR7Pq34f/iDv8x65yfHOQI1wygKZhg8gJJpEmCn4cUvDYMwCZxsCrxUJV4kAxZ5qIPCujNJRaC5FDBnXFRr8OoAWENIUGmW6CsuVMc9fm2168ev+1Aul+72ngEyJYXZddqu0zKtHwFTKqVEHlmUInAFTBAjGqeY0HKc0HgC9cdiWKi8aTYmFSA/hVkbjk/g5gbK81CPEJpwd/cL6BkKsjJhM2omMoEXTKQncMo0f0SCAwtizlptpbo3SxN1wp11qnVO2wxpXExHfI6dMhiyW8w4AcphFiwJ6FTnQEOZAyh5qlrQXyL2jMlvpC7dFeHHRLIwYEpndBT9uQWGMuqXbm2vXxUhxuRsgGEa4MfnA762hJZ5C6VAk34eyEBiwUMaO8uCiv4NeElde+hrLf+Djta7400Qo5/NF6U5RV3AUCvopWBHx4B/7+pF8amgCFoCn88x5Exj9Ey3LNWhXGRGGMwkNHOCdZqITBorcONVwldq2nGH/oB4hFxLcNnflQNR/HXkDze6ros9J1oGWgxy0nEbZ73Lvn8+8LvD634bdjavEMYv93an8V90Qe7PvRAfPZFGEZyev205eZ67CikdeJnqcgEJpMjW1ABVLKlIFud+RxZisnWOe/bQ8VcJdmanam7ZKvNibGY0IuZacHZ2ZlHvuiIhu7YW9a9HftuQHb+QZJmYoqlHzyAnwLUCmeo41UYDgZzPmQgVEU8la8GJHHecIHtwt0RHABRSfB8qymu8y9HSfiEw0LRyW63eNOsf7k5qt7XGO++25fHKHqhZPhaoRbrACsWcsweqmRrUnM70PRV6gz2h2vkEpscoqCo2R9D4pIFNtKE1kQEqRYdWIx+2+BoD6kD0QX85wI3kXgyQ4vVw4du3A+Cg09m1Lskzk86f3UH/sn/RLkAlJojWEDWxkoMgkshDA1anZOW77/Cgdf72NL+mAsmTkpSTijHgJLej90AVynYWBVMpQ/OfAJEpsdL+ssH184edu3uwRKwrdaFEmGYSyemUyIU4TWKpSD62g5nclCaOEhs5VUYD9ABYCLuBIPMCP3UEdzi67PWgd31x4X+i4tC+FcdVTTyZGnBy+h0trwjJElhd19KxlC7rdunOr+u6KFQ+93wf1j+VbE1pGdPI9g5oqWwyoEug8X6ctYDcjnyX4m23m+0OEKT0FDIVu1j7bWfI7PvIDGRaP106+wwKx5b7OlDVi7V8bF5lh+o4RrsOqYu3djTATZfgdNWYSTV3kqHqtOznKrvmAbckLVNbS6kuy3G2emVo30qw+aJeV80dwptt2mrZG2DzVMo3UWix81AqoC+aZjxFCvcZlZFbC9tkANao6p2VmUWz9mQKGyxYfmOsskiuJPsVaa3/Mf9qdW0LdWjlfvayYExLQQsbvsOFXc5SdzdsLudu4SqvxGKvsYFEk7+6zj/vC4g9hgwAAA=='
declare -r PZ_BASHRC_GZ_BASE64='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'

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
