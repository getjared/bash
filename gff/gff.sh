#!/bin/bash

# Gollum's File Finder (gff.sh)
# by jared @ https://github.com/getjared

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Array of Gollum-like phrases
phrases=(
    "Where is it? Where is my precious?"
    "Is it here? No, not here, sneaky little fileses."
    "We wants it, we needs it. Must have the precious."
    "It must be here, mustn't it, precious?"
    "Curse those nasty fileses, where are they hiding?"
    "Sneaky fileses, trying to trick us!"
    "We will find it, yes we will..."
    "Not this way... maybe that way?"
    "So close, so close..."
    "Come to Smeagol..."
    "Tricksy files, they hides from us!"
    "Where did they put it? Nasty hobbitses!"
    "Must search harder, gollum, gollum."
    "In the depths, in the dark, we looks."
    "Sneaking, creeping, searching we are."
    "Precious is calling for us, we must find!"
    "Smeagol knows it's here, yes, yes!"
    "Clever files, hiding from poor Smeagol."
    "We sniffs and snuffs for precious."
    "Deeper we goes, darker it gets, still searching."
)

# Function to output a Gollum-like phrase
function gollum_speak() {
    local phrase_index=$(( RANDOM % ${#phrases[@]} ))
    echo -e "${YELLOW}${phrases[$phrase_index]}${NC} ${CYAN}(Searching in $1)${NC}"
}

# Function to search for the file
function search_file() {
    local start_dir="$1"
    local search_file="$2"
    
    gollum_speak "$start_dir"
    
    # Use find command to search for the file (case-insensitive)
    result=$(sudo find "$start_dir" -iname "$search_file" -print -quit 2>/dev/null)
    
    if [ -n "$result" ]; then
        echo -e "${GREEN}My precious! We founds it!${NC}"
        echo -e "${PURPLE}Path: $result${NC}"
        echo
        return 0
    fi
    
    return 1
}


echo

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo, precious!${NC}"
    exit 1
fi

# Get the filename to search for
if [ -z "$1" ]; then
    echo -e "${YELLOW}What's the name of your precious file? Sneaky hobbitses!)${NC}"
    read -p "> " search_file
else
    search_file="$1"
fi

echo
echo -e "${GREEN}Gollum begins the hunt for the precious file '$search_file'...${NC}"
echo -e "${CYAN}(We'll find it no matter, yes we will!)${NC}"
echo

# Start the search from root directory
if search_file "/" "$search_file"; then
    exit 0
else
    echo
    echo -e "${RED}We couldn't find it! Lost, lost forever!${NC}"
    exit 1
fi
