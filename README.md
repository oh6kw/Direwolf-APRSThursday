# Direwolf-APRSThursday
Script for Direwolf APRS user to automatically join #APRSThursday

Direwolf-APRSThursday Net Automation ScriptScript for Direwolf APRS users to automatically check-in, participate, and unjoin the weekly #APRSThursday net via the ANSRVR net server.

🚀 Key Features
Multi-Callsign Support: Define multiple callsigns (e.g., base station, mobile, portable) to check in sequentially.
Time-Delayed Unjoin: Automatically sends the net unjoin command (U HOTG) after a defined delay (default 5 minutes).
Crontab Ready: Designed for reliable, automated execution on Linux/Unix systems (e.g., Raspberry Pi).
KISS TCP Interface: Uses the kissutil utility to communicate directly with Dire Wolf via TCP/IP.

⚙️ PrerequisitesA functioning Linux system (e.g., Raspberry Pi, Debian, Ubuntu).
Dire Wolf TNC running and configured to accept KISS TCP connections (default port 8001).
The kissutil utility installed and available in the system's PATH.

🛠️ Installation and Setup
1. Save the ScriptSave the script to a location on your system, for example:Bash/home/user/scripts/aprs.sh
2. Set Execution Permissions
3. Make the script executable: Bashchmod +x /home/user/scripts/aprs.sh
4. Configure User Settings
Open the script (aprs.sh) and edit the following section under USER CONFIGURABLE SETTINGS:

-Your callsign(s) as a space-separated list.("OH6KW" "OH6AH" "OH6RDA")
-CUSTOM_MESSAGE The custom text sent after "Happy APRSThursday from Finland!"
-CALL_DELAY Delay in seconds between checking in consecutive callsigns.
-UNJOIN_DELAY Delay in seconds before sending the unjoin command.

📅 Automation with CrontabThis script is designed to be run weekly via Crontab.
1. Open the Crontab EditorRun the following command for the user that runs Dire Wolf: crontab -e
2. Add the Job To run the script example every Thursday at 19:00 (7 PM) local time and log all output to a file for troubleshooting, add this single line to your crontab file:

# Runs the APRSThursday net script every Thursday at 19:00 (7 PM).
00 19 * * 4 /home/user/scripts/aprs.sh >> /var/log/aprs_log.log 2>&1
