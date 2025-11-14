#!/bin/bash
# APRS CQ HOTG message sending script via Direwolf for multiple callsigns.

# =================================================================
# USER CONFIGURABLE SETTINGS
# =================================================================
# 1. List of participating callsigns (separate with spaces).
# You can add or remove callsigns here.
CALL_SIGNS=("OH6KW" "OH6AH" "OH6RDA")

# 2. Custom message content (CQ HOTG will be added automatically).
# NOTE: The callsign used for sending will be appended automatically.
CUSTOM_MESSAGE="Happy APRSThursday from Finland!"

# 3. Delay in seconds between sending messages for consecutive callsigns.
# Recommendation: at least 30 seconds to prevent overlapping transmissions.
CALL_DELAY=30

# 4. Delay (in seconds) before the Unjoin command is sent (300s = 5 min).
UNJOIN_DELAY=300

# =================================================================
# SYSTEM SETTINGS (Do not modify unless you know what you are doing)
# =================================================================
DEST="ANSRVR"
PATHS="WIDE1-1,WIDE2-1"
UNJOIN_MESSAGE="U HOTG"
KISSHOST="127.0.0.1"
KISSPORT="8001"
CQ_PREFIX="CQ HOTG "
# =================================================================


# Find kissutil and date commands for robustness
KISSUTIL=$(command -v kissutil || echo "/usr/local/bin/kissutil")
DATECMD=$(command -v date || echo "/bin/date")

echo "== APRSthursday Net Startup: $("${DATECMD}" '+%Y-%m-%d %H:%M:%S') =="

# Check if kissutil is found
if [ ! -x "$KISSUTIL" ]; then
    echo "Error: kissutil command not found. Check installation."
    exit 1
fi

# -----------------------------------------------------------------
# 1. LOOP: Send Check-in message (CQ HOTG) for each callsign
# -----------------------------------------------------------------
for SRC in "${CALL_SIGNS[@]}"; do
    MESSAGE=":ANSRVR   :${CQ_PREFIX}${CUSTOM_MESSAGE} de $SRC"

    echo ""
    echo "== Sending Check-in for callsign: $SRC =="
    echo "  Destination:    $DEST" echo "  Message:        ${MESSAGE}"

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
    sleep $UNJOIN_DELAY

    echo "== Sending automatic Unjoin message to ANSRVR for ALL callsigns =="

    for SRC in "${CALL_SIGNS[@]}"; do
        echo "  >> Sending Unjoin for callsign: $SRC"

        UNJOIN_PAYLOAD=":ANSRVR   :${UNJOIN_MESSAGE}"

        echo "${SRC}>${DEST},${PATHS}:${UNJOIN_PAYLOAD}" | "$KISSUTIL" -h "$KISSHOST" -p "$KISSPORT" -v

        # Small delay between unjoins for safety (5s)
        sleep 5
    done

    # Timestamp
    echo "== All Unjoin messages sent at $("${DATECMD}" '+%H:%M:%S') =="

) &

# Main script exits immediately. The background process handles the Unjoin.
exit 0
