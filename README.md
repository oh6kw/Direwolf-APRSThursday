<h1 align="center">🐺 Direwolf-APRSThursday Net Automation Script</h1>

<p align="center">
    A BASH script for Direwolf APRS users to automatically check-in, participate, and unjoin the weekly <b>#APRSThursday</b> net via the <b>ANSRVR</b> net server.
</p>

<p align="center">
    <strong>✨ NEW FEATURE: Random Message Selection for Varied Check-ins! ✨</strong>
</p>

<hr>

<h2>🚀 Key Features</h2>
<ul>
    <li><strong>Randomized Messages:</strong> Selects a random greeting from a configurable list for each check-in, making your transmissions unique every week.</li>
    <li><strong>Multi-Callsign Support:</strong> Define multiple callsigns (e.g., base station, mobile, portable) to check in sequentially.</li>
    <li><strong>Time-Delayed Unjoin:</strong> Automatically sends the net unjoin command (<code>U HOTG</code>) after a defined delay (default 5 minutes).</li>
    <li><strong>Crontab Ready:</strong> Designed for reliable, automated execution on Linux/Unix systems (e.g., Raspberry Pi).</li>
    <li><strong>KISS TCP Interface:</strong> Uses the <code>kissutil</code> tool to communicate directly with Dire Wolf via TCP/IP.</li>
</ul>

<h2>⚙️ Prerequisites</h2>
<ol>
    <li>A functioning Linux system (e.g., Raspberry Pi, Debian, Ubuntu).</li>
    <li><strong>Dire Wolf</strong> TNC running and configured to accept KISS TCP connections (default port <strong>8001</strong>).</li>
    <li>The <strong><code>kissutil</code></strong> utility installed and available in the system's PATH.</li>
</ol>

<h2>🛠️ Installation and Setup</h2>

<h3>1. Save the Script</h3>
<p>Save the script provided below to a location on your system, for example. The recommended filename is <strong><code>aprs-net-checkin.sh</code></strong>:</p>
<pre><code>/home/user/scripts/aprs-net-checkin.sh</code></pre>

<h3>2. Set Execution Permissions</h3>
<p>Make the script executable:</p>
<pre><code>chmod +x /home/user/scripts/aprs-net-checkin.sh</code></pre>

<h3>3. Configure User Settings</h3>
<p>Open the script (<code>aprs-net-checkin.sh</code>) and edit the following section under <strong><code>USER CONFIGURABLE SETTINGS</code></strong>:</p>

<table>
    <thead>
        <tr>
            <th>Variable</th>
            <th>Description</th>
            <th>Default Value Example</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>CALL_SIGNS</code></td>
            <td>Your callsign(s) as a space-separated list.</td>
            <td><code>("OH6KW" "OH6AH" "OH6RDA")</code></td>
        </tr>
        <tr>
            <td><code>CUSTOM_MESSAGES</code></td>
            <td>A list of greetings. One will be chosen randomly for each check-in.</td>
            <td><code>("Happy APRSThursday!" "73 from the QTH.")</code></td>
        </tr>
        <tr>
            <td><code>CALL_DELAY</code></td>
            <td>Delay in seconds between checking in consecutive callsigns.</td>
            <td><code>30</code></td>
        </tr>
        <tr>
            <td><code>UNJOIN_DELAY</code></td>
            <td>Delay in seconds before sending the unjoin command.</td>
            <td><code>300</code> (5 min)</td>
        </tr>
    </tbody>
</table>

<h2>📅 Automation with Crontab</h2>
<p>This script is designed to be run weekly via <strong>Crontab</strong>.</p>

<h3>1. Open the Crontab Editor</h3>
<p>Run the following command for the user that runs Dire Wolf:</p>
<pre><code>crontab -e</code></pre>

<h3>2. Add the Job</h3>
<p>To run the script every <strong>Thursday at 19:00 (7 PM) local time</strong>, and log all output to a file (recommended location <code>/var/log/aprs-net-checkin.log</code>), add this single line to your crontab file:</p>

<pre><code># Runs the APRSThursday net script every Thursday at 19:00 (7 PM).
00 19 * * 4 /home/user/scripts/aprs-net-checkin.sh >> /var/log/aprs-net-checkin.log 2>&1</code></pre>

<table>
    <thead>
        <tr>
            <th>Field</th>
            <th>Value</th>
            <th>Meaning</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td align="center"><strong>00</strong></td>
            <td>Minute</td>
            <td>00</td>
        </tr>
        <tr>
            <td align="center"><strong>19</strong></td>
            <td>Hour (24h)</td>
            <td>19 (7 PM)</td>
        </tr>
        <tr>
            <td align="center"><strong>*</strong></td>
            <td>Day of Month</td>
            <td>Every day</td>
        </tr>
        <tr>
            <td align="center"><strong>*</strong></td>
            <td>Month</td>
            <td>Every month</td>
        </tr>
        <tr>
            <td align="center"><strong>4</strong></td>
            <td>Day of Week</td>
            <td>Thursday (0=Sun, 4=Thu)</td>
        </tr>
    </tbody>
</table>

<blockquote>
    <strong>Note:</strong> Ensure your system's clock and timezone are set correctly. Crontab uses the system's default timezone unless otherwise specified.
</blockquote>

<hr>

