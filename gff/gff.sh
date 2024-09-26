#!/bin/bash

# gollum's file finder (gff.sh)
# by jared @ https://github.com/getjared

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # no color

# array of gollum-like phrases
phrases=(
    "where is it? where is my precious?"
    "is it here? no, not here, sneaky little fileses."
    "we wants it, we needs it. must have the precious."
    "it must be here, mustn't it, precious?"
    "curse those nasty fileses, where are they hiding?"
    "sneaky fileses, trying to trick us!"
    "we will find it, yes we will..."
    "not this way... maybe that way?"
    "so close, so close..."
    "come to smeagol..."
    "tricksy files, they hides from us!"
    "where did they put it? nasty hobbitses!"
    "must search harder, gollum, gollum."
    "in the depths, in the dark, we looks."
    "sneaking, creeping, searching we are."
    "precious is calling for us, we must find!"
    "smeagol knows it's here, yes, yes!"
    "clever files, hiding from poor smeagol."
    "we sniffs and snuffs for precious."
    "deeper we goes, darker it gets, still searching."
)

# function to output a gollum-like phrase
function gollum_speak() {
    local phrase_index=$(( RANDOM % ${#phrases[@]} ))
    echo -e "${YELLOW}${phrases[$phrase_index]}${NC} ${CYAN}(searching in $1)${NC}"
}

# function to comment on file type
function gollum_file_type_comment() {
    local file="$1"
    local file_extension="${file##*.}"
    local file_type=$(file -b "$file")
    
    case "$file_extension" in
        c|h)
            echo -e "${YELLOW}c file, precious! sneaky pointers, yes, yes!${NC}"
            ;;
        cpp|hpp|cxx|hxx)
            echo -e "${YELLOW}c++ file, it is! objects everywhere, we hates them!${NC}"
            ;;
        py)
            echo -e "${BLUE}python file, slippery like snakes, yes!${NC}"
            ;;
        js)
            echo -e "${YELLOW}javascript file, async and tricky, precious!${NC}"
            ;;
        html|htm)
            echo -e "${PURPLE}html file, weaving webs like nasty spiders!${NC}"
            ;;
        css)
            echo -e "${BLUE}css file, makes things pretty, yes pretty!${NC}"
            ;;
        java)
            echo -e "${RED}java file, heavy like rocks, it slows us down!${NC}"
            ;;
        rb)
            echo -e "${RED}ruby file, shiny like gems, precious!${NC}"
            ;;
        php)
            echo -e "${PURPLE}php file, echoing in the dark, we hears it!${NC}"
            ;;
        go)
            echo -e "${BLUE}go file, fast and concurrent, it outruns us!${NC}"
            ;;
        rs)
            echo -e "${RED}rust file, no memory errors here, precious, no!${NC}"
            ;;
        sh|bash|zsh)
            echo -e "${GREEN}shell script, it whispers to the precious system, yes!${NC}"
            ;;
        sql)
            echo -e "${CYAN}sql file, queries the precious data, it does!${NC}"
            ;;
        json|yaml|yml|xml)
            echo -e "${YELLOW}data file, full of structured treasures!${NC}"
            ;;
        md|txt)
            echo -e "${GREEN}text file, full of secrets and stories, precious!${NC}"
            ;;
        *)
            case "$file_type" in
                *"shell script"*)
                    echo -e "${GREEN}sneaky shell script, it is! commands the system, yes!${NC}"
                    ;;
                *text*)
                    echo -e "${GREEN}text file, yes, but what kind, precious?${NC}"
                    ;;
                *executable*)
                    echo -e "${RED}nasty executable, it burns us!${NC}"
                    ;;
                *image*)
                    echo -e "${YELLOW}pretty picture for smeagol, yes!${NC}"
                    ;;
                *pdf*)
                    echo -e "${PURPLE}pdf, tricksy format it is, precious.${NC}"
                    ;;
                *directory*)
                    echo -e "${BLUE}a sneaky directory, full of secrets!${NC}"
                    ;;
                *)
                    echo -e "${CYAN}what's this file type, precious? we doesn't know, no.${NC}"
                    ;;
            esac
            ;;
    esac
}

# function to comment on file size
function gollum_file_size_comment() {
    local file="$1"
    local size=$(du -sh "$file" | cut -f1)
    
    case "$size" in
        *K)
            echo -e "${GREEN}tiny file, precious, yes! easy to swallow, it is!${NC}"
            ;;
        *M)
            if [[ ${size%M} -lt 10 ]]; then
                echo -e "${YELLOW}small file, but not too small, gollum gollum!${NC}"
            elif [[ ${size%M} -lt 100 ]]; then
                echo -e "${YELLOW}meaty file, gives us strength, yes!${NC}"
            else
                echo -e "${RED}big file, it is! makes our teeth ache, precious!${NC}"
            fi
            ;;
        *G)
            echo -e "${RED}it's a fat one, precious! too big to eat in one bite!${NC}"
            ;;
        *)
            echo -e "${CYAN}strange size, precious. we doesn't know what to think!${NC}"
            ;;
    esac
}

# function to handle easter eggs
function easter_egg() {
    local filename="$1"
    case "$filename" in
        *ring*)
            echo -e "${RED}the ring! the ring! we must have it, precious!${NC}"
            ;;
        *precious*)
            echo -e "${YELLOW}my precious! we found it at last, gollum gollum!${NC}"
            ;;
        *hobbit*)
            echo -e "${RED}nasty hobbitses! they stoles it from us!${NC}"
            ;;
        *fish*)
            echo -e "${BLUE}fish? is it juicy sweet? we likes it raw and wriggling!${NC}"
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

# function to search for the file
function search_file() {
    local start_dir="$1"
    local search_file="$2"
    
    gollum_speak "$start_dir"
    
    # use find command to search for the file (case-insensitive)
    results=$(sudo find "$start_dir" -iname "$search_file" 2>/dev/null)
    
    if [ -n "$results" ]; then
        # check for easter eggs
        if easter_egg "$search_file"; then
            echo
        fi

        # count the number of results
        count=$(echo "$results" | wc -l)
        
        if [ $count -eq 1 ]; then
            echo
            echo -e "${GREEN}my precious! we founds it!${NC}"
            echo -e "${PURPLE}path: $results${NC}"
            gollum_file_type_comment "$results"
            gollum_file_size_comment "$results"
            echo
        else
            echo
            echo -e "${YELLOW}oh! we found many preciouses! which one does we want?${NC}"
            echo
            
            # display results with numbers
            i=1
            while IFS= read -r result; do
                echo -e "${CYAN}$i)${NC} $result"
                i=$((i+1))
            done <<< "$results"
            
            echo
            echo -e "${YELLOW}which precious does we want? tell us the number, quick!${NC}"
            read -p "> " choice
            
            # validate choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $count ]; then
                chosen_file=$(sed "${choice}q;d" <<< "$results")
                echo
                echo -e "${GREEN}we takes this one, precious!${NC}"
                echo -e "${PURPLE}path: $chosen_file${NC}"
                gollum_file_type_comment "$chosen_file"
                gollum_file_size_comment "$chosen_file"
                echo
            else
                echo -e "${RED}silly choice! we doesn't understand, precious.${NC}"
                return 1
            fi
        fi
        return 0
    fi
    
    return 1
}

# check if running with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}please run as root or with sudo, precious!${NC}"
    exit 1
fi

# get the filename to search for
if [ -z "$1" ]; then
    echo -e "${YELLOW}what's the name of your precious file? sneaky hobbitses!)${NC}"
    read -p "> " search_file
else
    search_file="$1"
fi

echo
echo -e "${GREEN}gollum begins the hunt for the precious file '$search_file'...${NC}"
echo -e "${CYAN}(we'll find it no matter, yes we will!)${NC}"
echo

# start the search from root directory
if search_file "/" "$search_file"; then
    exit 0
else
    echo -e "${RED}we couldn't find it! lost, lost forever!${NC}"
    echo
    exit 1
fi
