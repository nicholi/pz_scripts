## About the scripts
These scripts are primarily my own means of documenting the setup of a Project Zomboid server to my own tastes. However they should be usable by anyone else (even if only to glean the knowledge they need to manually setup). Targeted primarily at a default Ubuntu server (always LTS variety) with absolutely no extra setup required beforehand. Most likely will work with any Debian variants as well. The only truly Ubuntu bit might be expecting the presence of snapd, used only in one small portion of script/functionality. Otherwise there is very little that is Debian/Ubuntu specific to the scripts, however I will attempt to smooth out any rigid distribution specifics. The scripts themselves are primarily targeted at BASH though, sorry POSIX be damned.

The scripts are also as idempotent as possible, meaning running them twice should never leave you in a broken state or completely erase something you had before (unless any of the `--clean*` parameters are used). In fact running again after a failed (or cancelled) execution will likely correct any mistakes and continue from where it left off. Obviously some files are intended to get overwritten, as you are running the installer again. Files are primarily installing to `/opt` locations, with a few files installed to `/usr/local` (easy addition to user's PATH).

### Folder hierarchy
There are 3 main areas. This allows for a clean separation of the SteamCMD client itself (used to install steam apps), the Project Zomboid game software itself (will need to be overriden on new build updates), and the actual Project Zomboid Multiplayer (MP) data.
- `/opt/steamcmd/` - SteamCMD client itself, no games or settings should be stored here.
- `/opt/steamgames/ProjectZomboid` - The Project Zomboid app software itself. Workshop items also get downloaded here, if any are used. No MP data is stored here.
- `/opt/steamdata/Zomboid` - The actual MP data stored for a PZ server. The player database, map data, server settings, sandbox settings, etc. This is where the important data that must be saved lives.

### Scripts
- `install_steamcmd.sh`: This script handles installing the SteamCMD client to `/opt/steamcmd`, and all necessary dependencies (from the perspective of an Ubuntu LTS server). Creates a `steam` user and assures enough privilege to interact with directory. If there ever are important updates to the SteamCMD client itself, this script could be run again to install the latest version.
  - `--clean`. Optional argument if you want to completely remove the `/opt/steamcmd` directory prior to installation.
- `install_projectzomboid.sh`: This script encapsulates 2 others (`pz_restart_graceful.sh` and `pz_workshop_update.sh`) as well as helpful bash functions (`pz.bashrc`). The `dev.aliases` file contains a small shell function to quickly gzip and base64 the scripts as variables for insertion into this script as they are further developed. This script's primary purpose is to install Project Zomboid with a systemd unit controlling the service, and some other useful admin functionality. It also initially sets up the server in a whitelist only mode (`Open=false` in settings), so the server is never left in an open state to anyone but you initially (with the admin user). It has a few optional parameters similar to the steamcmd script, if necessary to completely nuke directory hierarchies.
  - `--clean-game` - remove the game data directory
  - `--clean-data` - remove the MP data directory
  - `--clean-all` -  both of the above combined
- `pz_restart_graceful.sh`: Not intended to be run manually, but could be. Prior to **any** restart used by any of these services we first check the player count on server. If there are no players present we immediately trigger a shutdown. If there are any players we send a server broadcast message with a 30min countdown, giving them ample time to get to a safe location to logout. Message updates occur every 5 minutes thereafter, and at the final 1 minute countdown. At each update the player count is again checked, and if no users are online the shutdown is triggered. At which point the PZ server is safely stopped, backup taken of all MP data, and finally server turned back on. Normally taking about 90 seconds, depending on how much MP data there is (most of the time spent compressing with 7z).
- `pz_workshop_update.sh`: Also not intended to be run manually. Checking the gamedata ACF file on server for any installed workshop items and their last update timestamp, against the actual workshop items current data from the Steamworks Web API. If any workshop items are shown to be out of date, we will broadcast this message to all users and begin a scheduled restart. This is a rather important script, as workshop devs can update their mods at any point which will immediately get installed on user's machines when they startup Project Zomboid. The PZ server only gets workshop item updates when it restarts (once a day on our defaults), and if the workshop item is out of date between server and client that user will not be able to connect. By frequently triggering this script we can be sure our workshop items are up to date, and restart server if necessary. Leaving only a 30 minute window of user's being un-connectable if your admin is asleep/afk.
- `pz.bashrc`: Handy functions to use directly from the shell to administer server (all going through RCON interface). Very useful rather than starting up Project Zomboid to login as your admin user (though some things can only be done through the game UI still).

### How-to run
Install SteamCMD:
- From a command prompt run:
  - `sudo ./install_steamcmd.sh`
- No additional parameters necessary, and the script will not prompt for any additional input. There isn't much to do, so this one is rather simple.

Install Project Zomboid:
- From a command prompt run:
  - `sudo ./install_projectzomboid.sh ServerNameHere`
  - ex: `sudo ./install_projectzomboid.sh ChaosKingdom`
- The server name is only for file organizational purposes, not the display name of server anywhere. The intention being it should be possible to run multiple servers on a single machine, and separating each logical server's setting with the ServerName as a directory name. Have not actually tried this yet. Other aspects of my setup will need to be changed to call for running multiple servers.
- 1st Run: You will be prompted for 2 different passwords.
  - RCON password: A nifty standardized steam interface for "remote console" work. Almost all of the admin functionalities used in these scripts are only possible with setting this up. To run the base PZ server by itself it is not strictly necessary (if all you want is only `pz-server.service` working).
  - Admin password: The first user created for server with admin privileges. This password will be natively inserted into the sqlite db used by PZ. A lot of this is reverse engineered work and may break in future if their table schema or password salting techniques change (will just need to update to what their current techniques are). I feel this is still the best option, rather than exposing your admin password on the commandline. Which seems to be the only other viable solution used by other installers (LinuxGSM bless their hearts).
- 2nd Run (and all additional runs): it will only prompt for any passwords which do not seem to be setup correctly (or are blank). Most of the time the script will simply be validating the game data for PZ through SteamCMD, and if there are any updates to the self-contained scripts here they will be overwritten with latest versions.
- After the script has completed Project Zomboid is not running yet:
  - `sudo systemctl start pz-server.service`
- You can view the console output of the server through systemd with `journalctl -f -n 200 -u pz-server.service` (using ctrl+c to cancel, as it will **f**ollow the server output).

At this point everything should be totally setup on the server. You will be able to do a full reboot even (`sudo reboot`), and upon startup the `pz-server.service` will immediately start itself. Meaning your game should never go down. All background services are already running as well. ENJOY!

### Further explanation of things happening in the background
- `pz-scheduled-restart.timer`: Daily scheduled backup and restart set to occur at 12PM PST. When activated will trigger the oneshot service `pz-scheduled-restart.service`, which itself is executing the `pz_restart_graceful.sh` script. MP data backups will be saved into `/opt/steamdata/Backups` with a human readable timestamp in filename. Up to 2 weeks of backups are stored by default. Removal of older backups controlled by a small cron script (`/etc/cron.daily/pz-purge-backups`).
- `pz-workshop-update.timer`: Polling every 30 minutes to check for workshop item updates. When activated is triggering `pz-workshop-update.service` which is executing the `pz_workshop_updates.sh` script.
- After you have reloaded your current ssh session (or manually loading via `source /usr/local/etc/pz.bashrc`) handy admin functions have been added to call directly from the shell.
  - ex: `pz_broad "Hello users of the server"`
    - To send a broadcast message to all users. Various other functions have been added as well.
  - `rcon_cmd`: Generic function to run any RCON command.
  - etc...

### Final Notes
These scripts are primarily intended to simplify and consolidate the logic for installation/setup of Steam and Project Zomboid but **NOT** general administration of a linux server. I have skipped these boring parts.

The general recommendations I would have are:
- Protect your SSH access by **NEVER** using passwords (ssh keys only)
- Do not utilize the "root" user for SSH administration. Disabling it's SSH usage typically being the best.
- Install and configure fail2ban (`sudo apt-get install fail2ban`). The defaults are good enough.
- Restrict incoming ports with iptables.

The strictly necessary inbound ports which must be opened to run PZ are:
```
TCP: 16262-16361
UDP: 8766,8767,16261
```
The TCP range might actually be older deprecated PZ server info, it is hard to find up to date verifiable info. The range previously was meant to apply for how many users you would want connectable, the default range shown above being 100.

The RCON interface also has its own port (default 27015). However all the utilities we are using are local to the machine it **DOES NOT** need to be open, unless you intend to use the RCON interface from other remote locations. Be aware this is like full admin access to your PZ instance.

#### SystemD Timers
SystemD timers can be easily overriden in a standard fashion (google it). And literally **ANY** schedule can be created for the timers. Better to not edit the files installed by script, as they will be overwritten if script is run again.

Ex: to override the time of `pz-scheduled-restart.timer` to 8PM PST
```shell
# first display the timer's current schedule, should show 20:00:00 UTC
systemctl list-timers --all pz-scheduled-restart

sudo mkdir -p /etc/systemd/system/pz-scheduled-restart.timer.d
sudo tee /etc/systemd/system/pz-scheduled-restart.timer.d/override.conf <<< '[Timer]
# blank entry to first erase parent setting
OnCalendar=
# 8PM PST (4AM UTC)
OnCalendar=20:00:00 America/Los_Angeles
'

# NOTE: this may actually trigger the timer to run RIGHT NOW as well
sudo systemctl daemon-reload

# will show the timer's NEW next run
systemctl list-timers --all pz-scheduled-restart
```
