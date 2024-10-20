#!/bin/bash

SERVER="irc.libera.chat"
PORT=6667
NICK="sauronBot"
USER="sauron"
REALNAME="Bash IRC Client"
CHANNEL="#bash"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ERASE_LINE='\033[2K'
CURSOR_UP='\033[1A'

usage() {
    echo "Usage: $0 [-s server] [-p port] [-n nickname] [-u username] [-r realname] [-c channel]"
    exit 1
}

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

send_cmd() {
    echo -e "$1\r\n" >&3
}

exec 3<>/dev/tcp/"$SERVER"/"$PORT"

if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error: Could not connect to $SERVER on port $PORT.${RESET}"
    exit 1
fi

send_cmd "NICK $NICK"
send_cmd "USER $USER 0 * :$REALNAME"

cleanup() {
    send_cmd "QUIT :Bye"
    exec 3<&-
    exec 3>&-
    exit 0
}

trap cleanup INT TERM

receive_messages() {
    while IFS= read -r line <&3; do
        if [[ "$line" == PING* ]]; then
            send_cmd "PONG ${line#PING }"
            continue
        fi

        if [[ "$line" != *" 353 "* && "$line" != *" 366 "* && "$line" != *" 372 "* && "$line" != *" 375 "* && "$line" != *" 376 "* ]]; then
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
                :
            else
                echo -e "${BLUE}${line}${RESET}"
            fi
        fi

        if [[ "$line" == *" 001 "* ]]; then
            send_cmd "JOIN $CHANNEL"
            echo -e "${GREEN}━━━ Joined $CHANNEL ━━━${RESET}"
        fi
    done
}

receive_messages &

while IFS= read -r user_input; do
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
