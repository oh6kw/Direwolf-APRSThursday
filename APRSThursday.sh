#!/usr/bin/env bash
# APRS CQ HOTG message sending script via Direwolf for multiple callsigns.
# This script sends APRS messages to the ANSRVR net server via the Dire Wolf KISS TCP port.
# It selects a random message from the CUSTOM_MESSAGES array for each check-in.

# =================================================================
# USER CONFIGURABLE SETTINGS
# Modify only the contents of this block.
# =================================================================

# 1. List of participating callsigns (space-separated list).
CALL_SIGNS=("OH6KW" "OH6AH" "OH6RDA")

# 2. Custom messages (The 'CQ HOTG ' prefix will be added automatically).
# The script will randomly select one message from this list for each check-in.
CUSTOM_MESSAGES=(
    "Happy APRSThursday from Finland!"
    "Greetings from the land of aurora borealis!"
    "73 and all the best from the OH-land!"
    "QSY to the HOTG net freq, listening for traffic!"
    "Checking in from the shack for some Thursday fun."
    "Another week, another check-in! 73s to all."
    "Hope everyone is having a great thursday."
    "Enjoying the propagation tonight! Good luck to all."
    "Just testing. Cheers!"
    "APRS signals are strong tonight. Thanks for digipeating!"
    "Ready for the weekly APRS net. QSL?"
    "Sending QSLs digitally via this tiny packet."
    "Greetings from Finland, where the air is fresh!"
    "Running my QRP setup today. Low power, high hopes."
    "Enjoying a hot cup of coffee and the APRS net."
    "Have a fantastic evening, all net participants!"
    "This packet is dedicated to the digi-gods. Tnx!"
    "May your SWR be low and your signals strong."
    "73 to all the I-gates and digipeaters out there."
    "APRS is still the coolest tech in ham radio. Prove me wrong!"
    "Glad to be part of the HOTG community!"
)

# 3. Delay in seconds between sending messages for consecutive callsigns.
CALL_DELAY=30

# 4. Delay (in seconds) before the automatic Unjoin command is sent (e.g., 300s = 5 minutes).
UNJOIN_DELAY=300

# 5. The full path field used in the APRS packet (e.g., APRS,WIDE1-1,WIDE2-1).
# NOTE: This replaces the previous separate APRS prefix and PATHS settings.
APRS_PATH_FIELD="APRS,WIDE1-1,WIDE2-1"

# 6. Dire Wolf KISS TCP host address and port.
KISSHOST="127.0.0.1"
KISSPORT="8001"

# =================================================================
# SYSTEM SETTINGS (Do not modify)
# =================================================================
DEST="ANSRVR"
UNJOIN_MESSAGE="U HOTG"
CQ_PREFIX="CQ HOTG "
# ANSRVR message address (9 characters, padded with spaces)
ANSRVR_ADDR="ANSRVR   " 
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
    # --- RANDOM MESSAGE SELECTION LOGIC ---
    # Calculate the number of messages in the array
    MESSAGE_COUNT=${#CUSTOM_MESSAGES[@]}
    # Generate a random index number (0 to MESSAGE_COUNT - 1)
    RANDOM_INDEX=$(( RANDOM % MESSAGE_COUNT ))
    # Select the random message
    SELECTED_MESSAGE=${CUSTOM_MESSAGES[$RANDOM_INDEX]}
    # --------------------------------------

    # APRS message payload: ::ANSRVR   :CQ HOTG Message de CALL
    MESSAGE_PAYLOAD="${ANSRVR_ADDR}:${CQ_PREFIX}${SELECTED_MESSAGE} de $SRC"

    echo ""
    echo "== Sending Check-in for callsign: $SRC =="
    echo "  Destination (Payload): ${ANSRVR_ADDR}"
    echo "  Path Field:            ${APRS_PATH_FIELD}"
    echo "  Message Payload:       ${MESSAGE_PAYLOAD}"

    # Send the APRS message using the Extended Message format (::)
    # Format: SRC>PATH_FIELD::PAYLOAD
    echo "${SRC}>${APRS_PATH_FIELD}::${MESSAGE_PAYLOAD}" | "$KISSUTIL" -h "$KISSHOST" -p "$KISSPORT" -v

    # Timestamp
    echo "== Check-in sent at $("${DATECMD}" '+%H:%M:%S') =="

    # Wait before the next callsign, UNLESS it's the last callsign
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

        # APRS Unjoin message payload: ::ANSRVR   :U HOTG
        UNJOIN_PAYLOAD="${ANSRVR_ADDR}:${UNJOIN_MESSAGE}"

        # Send the APRS message using the Extended Message format (::)
        # Format: SRC>PATH_FIELD::PAYLOAD
        echo "${SRC}>${APRS_PATH_FIELD}::${UNJOIN_PAYLOAD}" | "$KISSUTIL" -h "$KISSHOST" -p "$KISSPORT" -v

        # Small delay between unjoins for safety (5s)
        sleep 5
    done

    # Timestamp
    echo "== All Unjoin messages sent at $("${DATECMD}" '+%H:%M:%S') =="

) &

# Main script exits immediately. The background process handles the Unjoin.
exit 0

