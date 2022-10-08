declare STEAMCMD_HOME=/opt/steamcmd
declare STEAMCMD_BIN="${STEAMCMD_HOME}/steamcmd.sh"

declare STEAM_GAMES_DIR=/opt/steamgames
declare PZ_HOME="${STEAM_GAMES_DIR}/ProjectZomboid"

declare STEAM_DATA_DIR=/opt/steamdata
declare PZ_DATA="${STEAM_DATA_DIR}/Zomboid"
declare PZ_DATABASE_DIR="${PZ_DATA}/db"

declare STEAM_DATA_BACKUP_DIR="${STEAM_DATA_DIR}/Backups"
declare PZ_SAVE_SLEEP=10s

declare STEAMCMD_USER=steam
declare PZ_USER=pz_user

declare PZ_RUN_STEAMCMD_UPDATE="${PZ_HOME}/.run_steamcmd_update"

declare PZ_NODE_PATH=/opt/pz_node_modules

declare CHAR_DOUBLEQUOTE='"'

function rcon_cmd() {
  rcon -c /etc/rcon/rcon.yaml "$@"
}

function pz_save() {
  rcon_cmd 'save'
}

function pz_quit() {
  rcon_cmd 'quit'
}

function pz_reloadoptions() {
  rcon_cmd 'reloadoptions'
}

function pz_changeoption() {
  local optionName="${1:-}"
  local optionValue="${2:-}"

  if [[ -z "${optionName}" ]]; then
    echo "WARNING: no option passed"
    return 1
  fi
  if [[ -z "${optionValue}" ]]; then
    echo "WARNING: no option value passed"
    return 1
  fi

  rcon_cmd "changeoption \"${optionName}\" \"${optionValue}\""
}

function pz_start() {
  sudo systemctl start pz-server.service
}

function pz_stop() {
  pz_quit
  sleep "${PZ_SAVE_SLEEP}"
  sudo systemctl stop pz-server.service
}

function pz_restart() {
  pz_quit
  sleep "${PZ_SAVE_SLEEP}"
  sudo systemctl restart pz-server.service
}

function pz_broad() {
  local message="$@"

  if [[ -z "${message}" ]]; then
    echo "WARNING: no message passed"
    return 1
  fi

  # project zomboid server only seems to allow receiving command arguments with double quotes
  rcon_cmd "servermsg \"${message}\""
}

function pz_players() {
  rcon_cmd 'players'
}

function pz_adduser() {
  local userName="${1:-}"
  local password="${2:-}"

  if [[ -z "${userName}" ]]; then
    echo "WARNING: no username passed"
    return 1
  fi
  if [[ -z "${password}" ]]; then
    password="$(makepasswd --chars=8)"
  fi

  rcon_cmd "adduser \"${userName}\" \"${password}\""
  echo -e "USERNAME: ${userName}\nPASSWORD: ${password}"
}

function pz_resetuser_password() {
  local serverName="${1:-}"
  local userName="${2:-}"
  local password="${3:-}"
  if [[ -z "${serverName}" ]]; then
    echo "WARNING: no serverName passed"
    return 1
  fi
  if [[ -z "${userName}" ]]; then
    echo "WARNING: no userName passed"
    return 1
  fi
  local databaseFile="${PZ_DATABASE_DIR}/${serverName}.db"
  if [[ ! -f "${databaseFile}" ]]; then
    echo "WARNING: db file not found for server -- ${databaseFile}"
    return 1
  fi

  hasPzUser "${databaseFile}" "${userName}" || { echo "WARNING: userName not found in db -- ${userName}"; return 1; }

  if [[ -z "${password}" ]]; then
    password="$(makepasswd --chars=8)"
  fi

  local bcryptPassword
  bcryptPassword="$(hashPzPassword "${password}")"

  # update password
  local sqlQuery="UPDATE [whitelist] SET [password] = '${bcryptPassword}', [encryptedPwd] = 'true', [pwdEncryptType] = 2
  WHERE [username] = '${userName}';
"
  sqlite3 "${databaseFile}" <<< "${sqlQuery}"
  echo "Reset ${userName} password to: ${password}"
}

function pz_additem() {
  local userName="${1:-}"
  local itemName="${2:-}"
  local itemCount="${3:-1}"

  if [[ -z "${userName}" ]]; then
    echo "WARNING: no username passed"
    return 1
  fi
  if [[ -z "${itemName}" ]]; then
    echo "WARNING: no item passed"
    return 1
  fi

  rcon_cmd "additem \"${userName}\" \"${itemName}\" ${itemCount}"
}

function pz_addvehicle() {
  local userName="${1:-}"
  local vehicleName="${2:-}"

  if [[ -z "${userName}" ]]; then
    echo "WARNING: no username passed"
    return 1
  fi
  if [[ -z "${vehicleName}" ]]; then
    echo "WARNING: no vehicle passed"
    return 1
  fi

  rcon_cmd "addvehicle \"${vehicleName}\" \"${userName}\""
}

function pz_addxp() {
  local userName="${1:-}"
  local perkName="${2:-}"

  if [[ -z "${userName}" ]]; then
    echo "WARNING: no username passed"
    return 1
  fi
  if [[ -z "${perkName}" ]]; then
    echo "WARNING: no perk passed"
    return 1
  fi

  rcon_cmd "addxp \"${userName}\" \"${perkName}\""
}

### graceful restart with message
### also backs up server
function pz_restart_graceful() {
  local restartReason="${1:-}"

  if [[ -n "${restartReason}" ]]; then
    pz_broad "${restartReason}"
  fi
  # everything triggering off the one systemd unit
  # should prevent double restarts (scheduled time of day and workshop update, or manual restart)
  sudo systemctl start pz-scheduled-restart.service
}

function pz_create_backup() {
  if [[ ! -d "${STEAM_DATA_BACKUP_DIR}" ]]; then
    echo "WARNING: Backup dir does not exist - ${STEAM_DATA_BACKUP_DIR}"
    return 2
  fi

  local backupDate="$(date -u +"%Y-%m-%dT%H-%M-%S")"
  sudo tar cf - --exclude='./Zomboid/Logs' --exclude='./Zomboid/backups' -C "${STEAM_DATA_DIR}" './Zomboid' | \
    7z a -si -t7z -m0=lzma2 -mx=4 -ms=on -mfb=64 -md=32m "${STEAM_DATA_BACKUP_DIR}/Zomboid_${backupDate}.tar.7z"
}

function pz_restore_backup() {
  local backupFile="$1"

  if [[ ! -f "${backupFile}" ]]; then
    echo "ERROR: backup file not found - ${backupFile}"
    return 2
  fi

  # as the backup restores EVERYTHING, we want to assure no old files remain
  # utilize pz_reset_server followed by extraction, this will keep our Logs dir untouched
  pz_reset_server 1 1
  7z x -so "${backupFile}" | sudo tar xf - -C "${STEAM_DATA_DIR}"
}

function pz_reset_server() {
  local purgeServerSettings="${1:-}"
  local purgeUserDb="${2:-}"

  local -a deleteDirs=(
    # mod additional settings?
    "${PZ_DATA}/Lua"
    # the actual saved data
    "${PZ_DATA}/Saves"
    # does not seem to get used in MP
    "${PZ_DATA}/Statistic"
    # always empty, possibly not relevant on dedicated MP servers
    "${PZ_DATA}/Workshop"
    # weird debug settings, possibly not relevant on MP
    "${PZ_DATA}/messaging"
    # possibly not relevant on MP
    "${PZ_DATA}/options.ini"
  )
  if [[ ${purgeServerSettings} -eq 1 ]]; then
    deleteDirs+=("${PZ_DATA}/Server")
  fi
  if [[ ${purgeUserDb} -eq 1 ]]; then
    deleteDirs+=("${PZ_DATA}/db")
  fi
  sudo rm -Rf "${deleteDirs[@]}"
}

### should only be run when server is stopped and backed up
function pz_reset_map_partial() {
  local serverName="${1}"
  local coordXRegex="${2}"
  local coordYRegex="${3}"

  if [[ -z "${serverName}" || -z "${coordXRegex}" || -z "${coordYRegex}" ]]; then
    echo 'Missing input parameters'
    return 1
  fi
  local pzServerSavesDir="${PZ_DATA}/Saves/Multiplayer/${serverName}"
  if [[ ! -d "${pzServerSavesDir}" ]]; then
    echo "Saves director does not exist for serverName - ${pzServerSavesDir}"
    return 2
  fi
  # escape pipes for find
  coordXRegex="${coordXRegex//|/\\|}"
  coordYRegex="${coordYRegex//|/\\|}"

  local findRegex files filesCount=0 keypress=''
  findRegex="${pzServerSavesDir}"'/map_\('"${coordXRegex}"'\)_\('"${coordYRegex}"'\)\.bin'
  files="$(sudo find "${pzServerSavesDir}" -type f -iregex "${findRegex}" | sort)"
  if [[ -n "${files}" ]]; then
    filesCount="$(wc -l <<< "${files}")"
  fi
  echo -e "Files:\n${files}"
  while [[ "${keypress,,}" != 'y' && "${keypress,,}" != 'n' ]]; do
    read -N1 -p "Prepared to delete the above ${filesCount} files? (Y/N) " keypress
  done
  echo

  if [[ "${keypress,,}" != 'y' ]]; then
    # not deleting
    echo 'NOT DELETING'
    return
  fi

  sudo find "${pzServerSavesDir}" -type f -iregex "${findRegex}" -delete
}

function parseAcfToJson() {
  local acfFile="${1}"

  if [[ ! -f "${acfFile}" ]]; then
    echo "ERROR: acf file not found - ${acfFile}" 1>&2
    return 1
  fi

  # impromptu nodejs app to parse acf into json and echo back to stdout
  local acfParserScript='try {
  const AcfParser = require("'"${PZ_NODE_PATH}/node_modules/steam-acf2json"'");
  const Fs = require("fs");
  const acfFile = Fs.readFileSync(process.argv[2], "utf-8");
  const decoded = AcfParser.decode(acfFile);
  console.log(JSON.stringify(decoded));
} catch (err) {
  console.error(err.stack);
  process.exit(1);
}
'

  node - "${acfFile}" <<< "${acfParserScript}"
}

function hashPzPassword() {
  local password="${1}"

  # holding any common nodejs modules under this path
  mkdir -p "${PZ_NODE_PATH}"

  local npmStdErr retval
  npmStdErr="$(npm install --prefix "${PZ_NODE_PATH}" bcryptjs 2>&1)"
  retval=$?
  if [[ ${retval} -ne 0 ]]; then
    echo "${npmStdErr}" 1>&2
    return ${retval}
  fi

  # we also want to assure to encode the password as a safe to pass javascript string
  local jsPassword
  jsPassword="$(jq '.' <<< "${CHAR_DOUBLEQUOTE}${password}${CHAR_DOUBLEQUOTE}" )"

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
  local hashedPassword
  hashedPassword="$(node - <<< "${hashPasswordScript}")"
  echo "${hashedPassword}"
}

function hasPzUser() {
  local databaseFile="${1}"
  local userName="${2}"

  local sqlQuery="SELECT '1' FROM [whitelist] WHERE [username] = '${userName}';"
  local sqlResult
  sqlResult="$(sqlite3 "${databaseFile}" <<< "${sqlQuery}")"
  if [[ "${sqlResult}" == '1' ]]; then
    # true
    return 0
  else
    # false
    return 1
  fi
}
