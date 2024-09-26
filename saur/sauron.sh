#!/bin/bash

# sauron irc client (sauron.sh)
# by jared @ https://github.com/getjared

# Configuration
SERVER="irc.libera.chat"    # Default IRC server
PORT=6667                   # Default IRC port
NICK="sauronBot"            # Default nickname
USER="sauron"               # Default username
REALNAME="Bash IRC Client"  # Real name
CHANNEL="#bash"             # Default channel to join

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Terminal control sequences
ERASE_LINE='\033[2K'
CURSOR_UP='\033[1A'

# Usage function
usage() {
    echo "Usage: $0 [-s server] [-p port] [-n nickname] [-u username] [-r realname] [-c channel]"
    exit 1
}

# Parse command-line arguments
while getopts "s:p:n:u:r:c:h" opt; do
    case $opt in
        s) SERVER="$OPTARG" ;;
        p) PORT="$OPTARG" ;;
        n) NICK="$OPTARG" ;;
        u) USER="$OPTARG" ;;
        r) REALNAME="$OPTARG" ;;
        c) CHANNEL="$OPTARG" ;;
        h|*) usage ;;
    esac
done

# Function to handle sending IRC commands
send_cmd() {
    echo -e "$1\r\n" >&3
}

# Open a TCP connection to the IRC server using /dev/tcp
exec 3<>/dev/tcp/"$SERVER"/"$PORT"

# Check if the connection was successful
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Could not connect to $SERVER on port $PORT.${RESET}"
    exit 1
fi

# Send IRC registration commands
send_cmd "NICK $NICK"
send_cmd "USER $USER 0 * :$REALNAME"

# Function to clean up on exit
cleanup() {
    send_cmd "QUIT :Bye"
    exec 3<&-
    exec 3>&-
    exit 0
}

trap cleanup INT TERM

# Function to handle incoming messages
receive_messages() {
    while IFS= read -r line <&3; do
        # Respond to PING to keep the connection alive (without displaying it)
        if [[ "$line" == PING* ]]; then
            send_cmd "PONG ${line#PING }"
            continue  # Skip to the next iteration of the loop
        fi

        # Filter out the user list, end of names list, and MOTD
        if [[ "$line" != *" 353 "* && "$line" != *" 366 "* && "$line" != *" 372 "* && "$line" != *" 375 "* && "$line" != *" 376 "* ]]; then
            # Parse and format the message
            if [[ "$line" == :*!*@*\ PRIVMSG\ * ]]; then
                sender="${line%%!*}"
                sender="${sender#:}"
                message="${line#*PRIVMSG ${CHANNEL} :}"
                if [[ "$sender" != "$NICK" ]]; then
                    echo -e "${BOLD}${CYAN}${sender}${RESET}${BOLD}:${RESET} ${message}"
                fi
            elif [[ "$line" == :*\ NOTICE\ * ]]; then
                echo -e "${MAGENTA}━━ ${line} ━━${RESET}"
            elif [[ "$line" == :*\ JOIN\ * ]]; then
                joiner="${line%%!*}"
                joiner="${joiner#:}"
                echo -e "${GREEN}▶ ${joiner} has joined the channel${RESET}"
            elif [[ "$line" == :*\ PART\ * ]]; then
                parter="${line%%!*}"
                parter="${parter#:}"
                echo -e "${YELLOW}◀ ${parter} has left the channel${RESET}"
            elif [[ "$line" == :*\ QUIT\ * ]]; then
                quitter="${line%%!*}"
                quitter="${quitter#:}"
                echo -e "${RED}✕ ${quitter} has quit${RESET}"
            elif [[ "$line" == :*\ MODE\ * ]]; then
                # Ignore mode messages
                :
            else
                echo -e "${BLUE}${line}${RESET}"
            fi
        fi

        # After registration, join the channel
        if [[ "$line" == *" 001 "* ]]; then
            send_cmd "JOIN $CHANNEL"
            echo -e "${GREEN}━━━ Joined $CHANNEL ━━━${RESET}"
        fi
    done
}

# Start receiving messages in the background
receive_messages &

# Read user input and send to IRC
while IFS= read -r user_input; do
    # Erase the line with the user input
    echo -en "${ERASE_LINE}${CURSOR_UP}${ERASE_LINE}\r"
    
    case "$user_input" in
        /quit*) cleanup ;;
        /join*)
            channel=$(echo "$user_input" | awk '{print $2}')
            send_cmd "JOIN $channel"
            CHANNEL="$channel"
            echo -e "${GREEN}━━━ Joining $CHANNEL ━━━${RESET}"
            ;;
        /msg*)
            target=$(echo "$user_input" | awk '{print $2}')
            message=$(echo "$user_input" | cut -d' ' -f3-)
            send_cmd "PRIVMSG $target :$message"
            echo -e "${YELLOW}[PM to ${target}]${RESET} ${message}"
            ;;
        *)
            send_cmd "PRIVMSG $CHANNEL :$user_input"
            echo -e "${BOLD}${CYAN}${NICK}${RESET}${BOLD}:${RESET} ${user_input}"
            ;;
    esac
done
