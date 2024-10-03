#!/bin/bash

# mapping from latin letters to klingon pIqaD code points
declare -A klingon_map=(
    ["a"]=$'\uF8D0'
    ["b"]=$'\uF8D1'
    ["ch"]=$'\uF8D2'
    ["d"]=$'\uF8D3'
    ["e"]=$'\uF8D4'
    ["gh"]=$'\uF8D5'
    ["H"]=$'\uF8D6'
    ["h"]=$'\uF8D6'
    ["I"]=$'\uF8D7'
    ["i"]=$'\uF8D7'
    ["j"]=$'\uF8D8'
    ["l"]=$'\uF8D9'
    ["m"]=$'\uF8DA'
    ["n"]=$'\uF8DB'
    ["ng"]=$'\uF8DC'
    ["o"]=$'\uF8DD'
    ["p"]=$'\uF8DE'
    ["q"]=$'\uF8DF'
    ["Q"]=$'\uF8E0'
    ["r"]=$'\uF8E1'
    ["S"]=$'\uF8E2'
    ["s"]=$'\uF8E2'
    ["t"]=$'\uF8E3'
    ["tlh"]=$'\uF8E4'
    ["u"]=$'\uF8E5'
    ["v"]=$'\uF8E6'
    ["w"]=$'\uF8E7'
    ["y"]=$'\uF8E8'
    ["'"]=$'\uF8E9'
)

# english to klingon word dictionary
declare -A klingon_dictionary=(
    # greetings
    ["hello"]="nuqneH"
    ["goodbye"]="Qapla'"
    ["hi"]="nuqneH"
    ["greetings"]="nuqneH"

    # pronouns
    ["i"]="jIH"
    ["you"]="SoH"
    ["we"]="maH"
    ["they"]="naDev"
    ["he"]="ghaH"
    ["she"]="ghaH"
    ["it"]="ghaH"

    # common phrases
    ["yes"]="HIja'"
    ["no"]="ghobe'"
    ["please"]="qa'plu'"
    ["thank"]="qatlho'"
    ["thanks"]="qatlho'"
    ["sorry"]="jIQoch"

    # nouns
    ["friend"]="jup"
    ["enemy"]="jagh"
    ["battle"]="veS"
    ["honor"]="batlh"
    ["Klingon"]="tlhIngan"
    ["empire"]="wo'"
    ["ship"]="Duj"
    ["starship"]="DujDaq"
    ["earth"]="tera'"
    ["star"]="Hov"
    ["fire"]="Hegh"
    ["water"]="ngaD"
    ["weapon"]="puq"
    ["weaponry"]="puqpu'"
    ["sword"]="QIch"
    ["blood"]="beq"

    # verbs
    ["attack"]="batlh"
    ["fight"]="batlh"
    ["love"]="bang"
    ["hate"]="QInvam"
    ["run"]="vItlhutlh"
    ["speak"]="tlhIngan Hol"

    # adjectives
    ["strong"]="vItlhutlh"
    ["brave"]="batlh"
    ["quick"]="pagh"
    ["swift"]="pagh"

    # others
    ["money"]="tlhegh"
    ["food"]="choq"
    ["leader"]="Qun"
    ["king"]="raS"
    ["queen"]="raS Qun"
    # add more words as desired
)

# function to translate english to klingon word-by-word
translate_to_klingon() {
    local sentence=("$@")
    local klingon_sentence=()
    local word translated_word

    # simple pluralization: append 'pu'' for people or 'mey' for objects
    pluralize() {
        case "$1" in
            jup|jagh|veS|batlh|tlhIngan|wo\'|Duj|DujDaq|Hov|Hegh|ngaD|puq|puqpu\'|QIch|beq|bang|QInvam|vItlhutlh|tlhIngan\ Hol|choq|Qun|raS|raS\ Qun)
                echo "${1}pu'"
                ;;
            *)
                echo "$1"
                ;;
        esac
    }

    # iterate over each word
    for word in "${sentence[@]}"; do
        # handle plural words
        if [[ "$word" == *"s" ]]; then
            base_word="${word%s}"
            if [ "${klingon_dictionary[$base_word]+_}" ]; then
                translated_word="$(pluralize "$base_word")"
                klingon_sentence+=("$translated_word")
                continue
            fi
        fi

        # translate word if exists in dictionary
        if [ "${klingon_dictionary[$word]+_}" ]; then
            klingon_sentence+=("${klingon_dictionary[$word]}")
        else
            klingon_sentence+=("$word")
        fi
    done

    # implement basic Object-Verb-Subject (OVS) word order
    # this is a naive implementation and works for simple sentences
    # example: "I attack enemy" -> "enemy attack I"

    # identify positions of subject, verb, object
    # for simplicity, assume sentences are in "Subject Verb Object" format
    # and reorder them to "Object Verb Subject"

    local subject=""
    local verb=""
    local object=""
    local reordered_sentence=()

    # find subject (pronouns or known subjects)
    for idx in "${!klingon_sentence[@]}"; do
        local w="${klingon_sentence[$idx]}"
        if [[ "$w" == "jIH" || "$w" == "SoH" || "$w" == "maH" || "$w" == "naDev" || "$w" == "ghaH" ]]; then
            subject="$w"
        fi
    done

    # find verb (from a set of known verbs)
    declare -A verbs
    verbs=( ["batlh"]=1 ["bang"]=1 ["QInvam"]=1 ["vItlhutlh"]=1 ["tlhIngan Hol"]=1 )

    for idx in "${!klingon_sentence[@]}"; do
        local w="${klingon_sentence[$idx]}"
        if [ "${verbs[$w]+_}" ]; then
            verb="$w"
        fi
    done

    # find object (remaining words)
    for w in "${klingon_sentence[@]}"; do
        if [[ "$w" != "$subject" && "$w" != "$verb" ]]; then
            object="$w"
        fi
    done

    # reorder to Object Verb Subject
    if [[ -n "$object" && -n "$verb" && -n "$subject" ]]; then
        reordered_sentence=("$object" "$verb" "$subject")
    else
        # if cannot determine, keep original order
        reordered_sentence=("${klingon_sentence[@]}")
    fi

    # join the reordered sentence into a single string
    echo "${reordered_sentence[@]}"
}

# function to convert translated Klingon words to pIqaD glyphs
convert_to_piqaD() {
    local translated_text="$1"
    local output_text=""
    local i=0
    local length=${#translated_text}

    while [ $i -lt $length ]; do
        # handle multicharacter symbols
        if [ "${translated_text:$i:3}" == "tlh" ]; then
            output_text+="${klingon_map["tlh"]}"
            i=$((i+3))
        elif [ "${translated_text:$i:2}" == "ch" ]; then
            output_text+="${klingon_map["ch"]}"
            i=$((i+2))
        elif [ "${translated_text:$i:2}" == "gh" ]; then
            output_text+="${klingon_map["gh"]}"
            i=$((i+2))
        elif [ "${translated_text:$i:2}" == "ng" ]; then
            output_text+="${klingon_map["ng"]}"
            i=$((i+2))
        elif [ "${translated_text:$i:3}" == "pu'" ]; then
            output_text+="${klingon_map["'"]}" # represent plural marker as apostrophe
            i=$((i+3))
        elif [ "${translated_text:$i:1}" == "'" ]; then
            output_text+="${klingon_map["'"]}"
            i=$((i+1))
        else
            char="${translated_text:$i:1}"
            if [ "${klingon_map[$char]+_}" ]; then
                output_text+="${klingon_map[$char]}"
            else
                # for characters not in the mapping, add them as is
                output_text+="$char"
            fi
            i=$((i+1))
        fi
    done

    echo -e "$output_text"
}

# main Loop
while true; do
    # Read user input
    read -p "Enter text (or type 'exit' to quit): " input_text

    # exit if user types 'exit' or an empty line
    if [ -z "$input_text" ] || [ "$input_text" == "exit" ]; then
        echo "Qapla'! (Success!)"
        break
    fi

    # convert input text to lower case
    input_text=$(echo "$input_text" | tr '[:upper:]' '[:lower:]')

    # split input into words
    IFS=' ' read -r -a words <<< "$input_text"

    # translate words to Klingon
    translated_sentence=$(translate_to_klingon "${words[@]}")

    # convert translated sentence to pIqaD glyphs
    piqad_text=$(convert_to_piqaD "$translated_sentence")

    # output the converted text
    echo -e "$piqad_text"
done

