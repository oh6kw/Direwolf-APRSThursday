#!/bin/bash
# APRS CQ HOTG message sending script via Direwolf for multiple callsigns.
# This script sends APRS messages to the ANSRVR net server via the Dire Wolf KISS TCP port.
# It handles check-in for multiple callsigns and automatically sends unjoin messages after a delay.

# =================================================================
# USER CONFIGURABLE SETTINGS
# =================================================================
# 1. List of participating callsigns (separate with spaces).
# Add or remove callsigns as needed.
CALL_SIGNS=("OH6KW" "OH6AH" "OH6RDA")

# 2. Custom message content (CQ HOTG prefix will be added automatically).
# NOTE: The transmitting callsign will be appended to the message automatically.
CUSTOM_MESSAGE="Happy APRSThursday from Finland!"

# 3. Delay in seconds between sending messages for consecutive callsigns.
# Recommended minimum: 30 seconds to prevent overlapping transmissions on the channel.
CALL_DELAY=30

# 4. Delay (in seconds) before the automatic Unjoin command is sent (e.g., 300s = 5 minutes).
UNJOIN_DELAY=300

# =================================================================
# SYSTEM SETTINGS (Do not modify unless necessary)
# =================================================================
# Destination address for the APRS frame (used as the destination field)
DEST="ANSRVR"
# APRS Path used for routing (WIDE1-1,WIDE2-1 is common for local RF)
PATHS="WIDE1-1,WIDE2-1"
# Unjoin message command as defined by the net server
UNJOIN_MESSAGE="U HOTG"
# Dire Wolf KISS TCP host address (typically localhost on the same machine)
KISSHOST="127.0.0.1"
# Dire Wolf KISS TCP port
KISSPORT="8001"
# CQ prefix added before the custom message
CQ_PREFIX="CQ HOTG "
# =================================================================


# Find kissutil and date commands for robustness in various environments (e.g., cron)
KISSUTIL=$(command -v kissutil || echo "/usr/local/bin/kissutil")
DATECMD=$(command -v date || echo "/bin/date")

echo "== APRSthursday Net Startup: $("${DATECMD}" '+%Y-%m-%d %H:%M:%S') =="

# Check if kissutil is found and executable
if [ ! -x "$KISSUTIL" ]; then
    echo "Error: kissutil command not found. Check installation."
    exit 1
fi

# -----------------------------------------------------------------
# 1. LOOP: Send Check-in message (CQ HOTG) for each callsign
# -----------------------------------------------------------------
for SRC in "${CALL_SIGNS[@]}"; do
    # APRS Message format: :ADDRESSEE :TEXT
    # The addressee (ANSRVR) must be exactly 9 characters long (padded with spaces).
    MESSAGE=":ANSRVR   :${CQ_PREFIX}${CUSTOM_MESSAGE} de $SRC"

    echo ""
    echo "== Sending Check-in for callsign: $SRC =="
    echo "  Destination:    $DEST"
    echo "  Message:        ${MESSAGE}"

    # Send the APRS message via kissutil to the Dire Wolf KISS TCP port.
    # Format: SRC>DEST,PATH:PAYLOAD (PAYLOAD contains the ANSRVR message format)
    echo "${SRC}>${DEST},${PATHS}:${MESSAGE}" | "$KISSUTIL" -h "$KISSHOST" -p "$KISSPORT" -v

    # Timestamp
    echo "== Check-in sent at $("${DATECMD}" '+%H:%M:%S') =="

    # Wait before the next callsign, UNLESS it's the last callsign
    # Uses Bash specific array slicing to check the last element
    if [[ "$SRC" != "${CALL_SIGNS[@]: -1}" ]]; then
        echo "  >> Waiting $CALL_DELAY seconds before the next transmission..."
        sleep $CALL_DELAY
    fi
done

# -----------------------------------------------------------------
# 2. LOOP: Start the Unjoin process in the background for ALL callsigns
# -----------------------------------------------------------------
(
    echo ""
    echo "  >> Unjoin process started in the background (delay: $UNJOIN_DELAY seconds)."
    # Wait for the defined delay before sending unjoin messages
    sleep $UNJOIN_DELAY

    echo "== Sending automatic Unjoin message to ANSRVR for ALL callsigns =="

    for SRC in "${CALL_SIGNS[@]}"; do
        echo "  >> Sending Unjoin for callsign: $SRC"

        # APRS Unjoin message payload (9-character padded ANSRVR)
        UNJOIN_PAYLOAD=":ANSRVR   :${UNJOIN_MESSAGE}"

        # Send the Unjoin message via kissutil
        echo "${SRC}>${DEST},${PATHS}:${UNJOIN_PAYLOAD}" | "$KISSUTIL" -h "$KISSHOST" -p "$KISSPORT" -v

        # Small delay between unjoins for safety (5s)
        sleep 5
    done

    # Timestamp
    echo "== All Unjoin messages sent at $("${DATECMD}" '+%H:%M:%S') =="

) &

# Main script exits immediately. The background process handles the Unjoin.
exit 0
