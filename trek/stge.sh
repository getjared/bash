#!/bin/bash

# Star Trek: Galactic Explorer (stge.sh)
# by jared @ https://github.com/getjared

# Initialize variables
VIEWPORT_WIDTH=20
VIEWPORT_HEIGHT=10
ENERGY=100
RESOURCES=0
SCORE=0
CREW=1000
MORALE=100
declare -A grid  # Holds the known universe
declare -A enemies  # Tracks active enemies and their movement counters

# Ship systems and their integrity
declare -A ship_systems=(
    ["Shields"]=100
    ["Weapons"]=100
    ["Engines"]=100
    ["Life Support"]=100
    ["Sensors"]=100
)

# Define maximum enemies per viewport
MAX_ENEMIES_PER_VIEWPORT=5  # Adjust this value to control enemy density

# Define color variables
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Crew Members and Bridge Crew
BRIDGE_CREW=("Captain Kirk" "First Officer Spock" "Chief Engineer Scott" "Chief Medical Officer McCoy" "Helmsman Sulu" "Communications Officer Uhura" "Navigator Chekov")
CREW_MEMBERS=()
for ((i=1; i<=CREW; i++)); do
    CREW_MEMBERS+=("Crew Member $i")
done

# Place the Enterprise at the origin (0,0)
function place_enterprise() {
    E_X=0
    E_Y=0
    grid[$E_X,$E_Y]="E"
}

# Count the number of enemies in the viewport
function count_enemies_in_viewport() {
    local count=0
    local start_x=$((E_X - VIEWPORT_WIDTH / 2))
    local end_x=$((E_X + VIEWPORT_WIDTH / 2))
    local start_y=$((E_Y - VIEWPORT_HEIGHT / 2))
    local end_y=$((E_Y + VIEWPORT_HEIGHT / 2))
    for ((y=start_y; y<end_y; y++)); do
        for ((x=start_x; x<end_x; x++)); do
            if [[ "${grid[$x,$y]}" =~ [KRBF] ]]; then
                ((count++))
            fi
        done
    done
    echo $count
}

# Procedurally generate content for a given coordinate
function generate_cell_content() {
    local x=$1
    local y=$2

    # Use a deterministic seed based on coordinates for consistent generation
    local seed=$((x * 10000 + y))
    RANDOM=$seed
    local roll=$((RANDOM % 100))

    # Check if maximum enemies in viewport reached
    local enemy_count=$(count_enemies_in_viewport)
    if [ $enemy_count -ge $MAX_ENEMIES_PER_VIEWPORT ]; then
        # Don't generate more enemies
        if [ $roll -lt 10 ]; then  # Slightly increased chance for planets
            grid[$x,$y]="P"  # Planet
        else
            grid[$x,$y]="·"  # Empty space
        fi
    else
        # Proceed with normal generation
        if [ $roll -lt 10 ]; then
            grid[$x,$y]="P"  # Planet
        elif [ $roll -lt 17 ]; then
            local enemy_types=("K" "R" "B" "F")  # Klingon, Romulan, Borg, Ferengi
            local enemy=${enemy_types[$((RANDOM % ${#enemy_types[@]}))]}
            grid[$x,$y]=$enemy
            # Initialize enemy movement counter
            enemies[$x,$y]=$((RANDOM % 3 + 1))  # Enemy moves in 1 to 3 turns
        else
            grid[$x,$y]="·"  # Empty space
        fi
    fi
}

# Display the grid around the Enterprise
function display_grid() {
    clear
    echo "${BOLD}Energy:${RESET} $ENERGY    ${BOLD}Resources:${RESET} $RESOURCES    ${BOLD}Score:${RESET} $SCORE    ${BOLD}Crew:${RESET} $CREW    ${BOLD}Morale:${RESET} $MORALE"
    echo "${BOLD}Position:${RESET} ($E_X, $E_Y)"
    echo ""
    local start_x=$((E_X - VIEWPORT_WIDTH / 2))
    local end_x=$((E_X + VIEWPORT_WIDTH / 2))
    local start_y=$((E_Y - VIEWPORT_HEIGHT / 2))
    local end_y=$((E_Y + VIEWPORT_HEIGHT / 2))

    for ((y=start_y; y<end_y; y++)); do
        for ((x=start_x; x<end_x; x++)); do
            # Generate cell content if not already known
            if [ -z "${grid[$x,$y]}" ]; then
                generate_cell_content $x $y
            fi
            cell=${grid[$x,$y]}
            if [ $x -eq $E_X ] && [ $y -eq $E_Y ]; then
                cell="E"
            fi
            case $cell in
                "·") echo -n "${BLUE}· ${RESET}";;  # Empty space
                "E") echo -n "${GREEN}E ${RESET}";; # Enterprise
                "P") echo -n "${YELLOW}P ${RESET}";; # Planet
                "K") echo -n "${RED}K ${RESET}";;  # Klingon Ship
                "R") echo -n "${MAGENTA}R ${RESET}";; # Romulan Ship
                "B") echo -n "${CYAN}B ${RESET}";;  # Borg Cube
                "F") echo -n "${YELLOW}${BOLD}F ${RESET}";;  # Ferengi Ship
                "M") echo -n "${RED}${BOLD}M ${RESET}";;  # Mirror Universe Indicator
            esac
        done
        echo ""
    done
    echo ""
    echo "Controls: W=Up, A=Left, S=Down, D=Right, V=View Crew, I=View Ship, R=Use Resources, Q=Quit"
}

# Handle movement
function move_enterprise() {
    read -n1 -s input
    input=${input,,}  # Convert to lowercase
    local new_x=$E_X
    local new_y=$E_Y

    case $input in
        w) ((new_y--));;
        s) ((new_y++));;
        a) ((new_x--));;
        d) ((new_x++));;
        v) view_crew; return;;
        i) view_ship; return;;
        r)
            if [ $RESOURCES -gt 0 ]; then
                ((ENERGY+=10))
                ((RESOURCES-=1))
                echo "Used 1 resource to restore 10 energy."
                sleep 1
            else
                echo "No resources available."
                sleep 1
            fi
            return;;
        q) exit_game;;
        *) return;;
    esac

    # Update grid
    E_X=$new_x
    E_Y=$new_y

    # Generate cell content if not already known
    if [ -z "${grid[$E_X,$E_Y]}" ]; then
        generate_cell_content $E_X $E_Y
    fi

    # Check for anomaly
    if [ $((RANDOM % 100)) -lt 3 ]; then  # 3% chance to encounter anomaly
        encounter_anomaly
    fi

    # Check for collision with enemy ships
    enemy=${grid[$E_X,$E_Y]}
    if [[ "$enemy" =~ [KRBF] ]]; then
        encounter_enemy "$enemy"
        if [ $CREW -le 0 ]; then
            game_over "All crew members have perished."
        fi
        # Remove enemy from enemies list if defeated
        unset enemies[$E_X,$E_Y]
        grid[$E_X,$E_Y]="·"
    fi

    # Check for planet
    if [ "${grid[$E_X,$E_Y]}" == "P" ]; then
        encounter_planet
        grid[$E_X,$E_Y]="·"
    fi

    # Decrease energy
    ((ENERGY--))
    if [ $ENERGY -le 0 ]; then
        game_over "You have run out of energy!"
    fi
}

# Handle planet encounter with more random events
function encounter_planet() {
    echo ""
    echo "You have discovered a planet!"
    sleep 1
    ((SCORE+=10))
    local event=$((RANDOM % 12))  # Increased range for new events
    case $event in
        0)
            echo "Friendly aliens provide you with energy."
            ((ENERGY+=20))
            ;;
        1)
            echo "Hostile aliens attack your ship!"
            casualties=$((RANDOM % 50 + 1))
            ((CREW-=casualties))
            ((MORALE-=10))
            echo "$casualties crew members lost."
            apply_ship_damage
            ;;
        2)
            echo "You collect valuable resources."
            ((RESOURCES+=2))
            ;;
        3)
            echo "You encounter a space anomaly. Energy drained."
            ((ENERGY-=15))
            apply_ship_damage
            ;;
        4)
            echo "You find ancient technology. Energy efficiency improved."
            ((ENERGY+=30))
            ;;
        5)
            echo "Distress signal received. Rescue mission successful."
            ((SCORE+=20))
            ((MORALE+=10))
            ;;
        6)
            echo "Nebula encountered. Sensors are malfunctioning."
            apply_system_damage "Sensors" $((RANDOM % 20 + 10))
            ;;
        7)
            echo "You meet alien beings who wish to join your crew!"
            new_crew=$((RANDOM % 20 + 5))
            ((CREW+=new_crew))
            ((MORALE+=5))
            echo "$new_crew alien crew members have joined your ship."
            ;;
        8)
            echo "A mysterious artifact is found on the planet."
            echo "Spock: \"Its origins are unknown, Captain.\""
            sleep 1
            echo "Do you wish to study it?"
            read -p "1) Yes  2) No : " choice
            if [ "$choice" == "1" ]; then
                echo "You study the artifact."
                local artifact_event=$((RANDOM % 2))
                if [ $artifact_event -eq 0 ]; then
                    echo "The artifact grants you advanced knowledge!"
                    ((SCORE+=50))
                    ((ENERGY+=20))
                else
                    echo "The artifact emits a harmful radiation!"
                    apply_ship_damage
                    ((MORALE-=10))
                fi
            else
                echo "You leave the artifact undisturbed."
            fi
            ;;
        9)
            echo "A time distortion occurs on the planet."
            echo "McCoy: \"I'm a doctor, not a time traveler!\""
            sleep 1
            echo "Your crew experiences strange visions."
            ((MORALE-=5))
            ;;
        10)
            echo "You find a rich deposit of dilithium crystals!"
            ((RESOURCES+=5))
            echo "Scotty: \"These will keep us running for a while, Captain!\""
            ;;
        11)
            echo "A peaceful alien civilization invites you to a grand feast."
            ((MORALE+=15))
            ((ENERGY+=10))
            echo "Your crew's spirits are lifted."
            ;;
    esac
    if [ $CREW -le 0 ]; then
        game_over "All crew members have perished!"
    fi
    read -p "Press Enter to continue..."
}

# Enemy encounter with more fun dialogs and events
function encounter_enemy() {
    local enemy_type=$1
    echo ""
    case $enemy_type in
        "K")
            echo "${RED}${BOLD}A Klingon Warbird uncloaks ahead!${RESET}"
            echo "Captain Kirk: \"Klingons off the starboard bow!\""
            sleep 1
            echo "Options:"
            echo "1) Engage in battle"
            echo "2) Attempt diplomacy"
            echo "3) Cloak and evade"
            read -p "Choose an action (1-3): " choice
            case $choice in
                1)
                    echo "You decide to engage in battle!"
                    sleep 1
                    combat_result=$((RANDOM % 2))
                    if [ $combat_result -eq 0 ]; then
                        echo "Spock: \"Their shields are down, Captain.\""
                        echo "Captain Kirk: \"Fire photon torpedoes!\""
                        echo "The Klingon ship explodes in a fiery blaze!"
                        ((SCORE+=30))
                        ((MORALE+=5))
                    else
                        echo "The Klingons fire disruptors!"
                        echo "Scotty: \"We've taken damage, Captain!\""
                        casualties=$((RANDOM % 100 + 50))
                        ((CREW-=casualties))
                        ((MORALE-=15))
                        ((ENERGY-=20))
                        apply_ship_damage
                        echo "$casualties crew members lost."
                    fi
                    ;;
                2)
                    echo "You open hailing frequencies."
                    echo "Uhura: \"Channel open, Captain.\""
                    echo "Captain Kirk: \"This is Captain James T. Kirk of the USS Enterprise...\""
                    sleep 1
                    local diplomacy=$((RANDOM % 2))
                    if [ $diplomacy -eq 0 ]; then
                        echo "The Klingons accept your offer of peace."
                        ((MORALE+=10))
                        echo "They share valuable tactical data."
                        ((SCORE+=25))
                    else
                        echo "The Klingons reject your overture and attack!"
                        sleep 1
                        echo "Battle ensues!"
                        combat_result=$((RANDOM % 2))
                        if [ $combat_result -eq 0 ]; then
                            echo "You outmaneuver the Klingon ship and it retreats."
                            ((SCORE+=20))
                            ((MORALE+=5))
                        else
                            echo "Your ship takes heavy damage!"
                            casualties=$((RANDOM % 80 + 20))
                            ((CREW-=casualties))
                            ((MORALE-=15))
                            apply_ship_damage
                            echo "$casualties crew members lost."
                        fi
                    fi
                    ;;
                3)
                    echo "You attempt to cloak and evade the Klingon ship."
                    sleep 1
                    local evade=$((RANDOM % 2))
                    if [ $evade -eq 0 ]; then
                        echo "You successfully evade the Klingon ship."
                        ((ENERGY-=5))
                    else
                        echo "The Klingons detect your cloaking attempt and attack!"
                        sleep 1
                        echo "Battle ensues!"
                        combat_result=$((RANDOM % 2))
                        if [ $combat_result -eq 0 ]; then
                            echo "You disable the Klingon ship's weapons and escape."
                            ((SCORE+=15))
                            ((MORALE+=5))
                        else
                            echo "Your ship takes heavy damage!"
                            casualties=$((RANDOM % 60 + 10))
                            ((CREW-=casualties))
                            ((MORALE-=15))
                            apply_ship_damage
                            echo "$casualties crew members lost."
                        fi
                    fi
                    ;;
                *)
                    echo "Invalid choice. The Klingons take advantage and attack!"
                    sleep 1
                    echo "Your ship takes damage!"
                    casualties=$((RANDOM % 50 + 10))
                    ((CREW-=casualties))
                    ((MORALE-=10))
                    apply_ship_damage
                    echo "$casualties crew members lost."
                    ;;
            esac
            ;;
        "R")
            echo "${MAGENTA}${BOLD}A Romulan Warbird decloaks!${RESET}"
            echo "Romulan Commander: \"You have trespassed into Romulan space.\""
            sleep 1
            echo "Options:"
            echo "1) Engage in battle"
            echo "2) Attempt to deceive"
            echo "3) Surrender"
            read -p "Choose an action (1-3): " choice
            case $choice in
                1)
                    echo "You decide to engage in battle!"
                    sleep 1
                    combat_result=$((RANDOM % 2))
                    if [ $combat_result -eq 0 ]; then
                        echo "You outmaneuver the Romulan ship and it retreats."
                        ((SCORE+=25))
                        ((MORALE+=5))
                    else
                        echo "The Romulans fire plasma torpedoes!"
                        echo "Scotty: \"Engineering is taking hits!\""
                        casualties=$((RANDOM % 80 + 20))
                        ((CREW-=casualties))
                        ((MORALE-=15))
                        apply_ship_damage
                        echo "$casualties crew members lost."
                    fi
                    ;;
                2)
                    echo "You attempt to deceive the Romulans."
                    echo "Spock: \"Transmitting false sensor readings.\""
                    sleep 1
                    local deceive=$((RANDOM % 2))
                    if [ $deceive -eq 0 ]; then
                        echo "The Romulans believe your deception and leave."
                        ((MORALE+=10))
                        echo "You safely continue your mission."
                    else
                        echo "The Romulans see through your deception!"
                        sleep 1
                        echo "They attack your ship!"
                        combat_result=$((RANDOM % 2))
                        if [ $combat_result -eq 0 ]; then
                            echo "You manage to escape with minimal damage."
                            ((SCORE+=15))
                        else
                            echo "Your ship takes significant damage!"
                            casualties=$((RANDOM % 70 + 30))
                            ((CREW-=casualties))
                            ((MORALE-=20))
                            apply_ship_damage
                            echo "$casualties crew members lost."
                        fi
                    fi
                    ;;
                3)
                    echo "You decide to surrender."
                    sleep 1
                    echo "Romulan Commander: \"A wise decision.\""
                    ((MORALE-=20))
                    echo "They confiscate your resources."
                    ((RESOURCES-=5))
                    if [ $RESOURCES -lt 0 ]; then RESOURCES=0; fi
                    echo "After detaining you, they release your ship."
                    ;;
                *)
                    echo "Invalid choice. The Romulans take advantage and attack!"
                    sleep 1
                    echo "Your ship takes damage!"
                    casualties=$((RANDOM % 50 + 10))
                    ((CREW-=casualties))
                    ((MORALE-=10))
                    apply_ship_damage
                    echo "$casualties crew members lost."
                    ;;
            esac
            ;;
        "B")
            echo "${CYAN}${BOLD}A Borg Cube approaches!${RESET}"
            echo "Borg Collective: \"We are the Borg. Resistance is futile.\""
            sleep 1
            echo "Options:"
            echo "1) Attempt to negotiate"
            echo "2) Engage in battle"
            echo "3) Use a deflector pulse"
            read -p "Choose an action (1-3): " choice
            case $choice in
                1)
                    echo "You attempt to negotiate with the Borg."
                    sleep 1
                    echo "Borg Collective: \"Negotiation is irrelevant.\""
                    echo "They begin assimilating your ship!"
                    casualties=$((CREW / 2))
                    ((CREW-=casualties))
                    ((MORALE-=30))
                    apply_ship_damage
                    echo "$casualties crew members assimilated."
                    ;;
                2)
                    echo "You decide to engage in battle!"
                    sleep 1
                    echo "The Borg adapt to your weapons!"
                    apply_ship_damage
                    casualties=$((CREW / 3))
                    ((CREW-=casualties))
                    ((MORALE-=25))
                    echo "$casualties crew members lost."
                    ;;
                3)
                    echo "You attempt to use a deflector pulse to disrupt the Borg."
                    sleep 1
                    local pulse=$((RANDOM % 2))
                    if [ $pulse -eq 0 ]; then
                        echo "The pulse is successful! The Borg Cube is temporarily disabled."
                        ((SCORE+=50))
                        ((MORALE+=10))
                        echo "You escape while they regenerate."
                    else
                        echo "The Borg adapt to the pulse frequency!"
                        echo "They begin assimilating your ship!"
                        casualties=$((CREW / 2))
                        ((CREW-=casualties))
                        ((MORALE-=30))
                        apply_ship_damage
                        echo "$casualties crew members assimilated."
                    fi
                    ;;
                *)
                    echo "Invalid choice. The Borg begin assimilation!"
                    sleep 1
                    casualties=$((CREW / 2))
                    ((CREW-=casualties))
                    ((MORALE-=30))
                    apply_ship_damage
                    echo "$casualties crew members assimilated."
                    ;;
            esac
            ;;
        "F")
            echo "${YELLOW}${BOLD}A Ferengi Marauder blocks your path!${RESET}"
            echo "Ferengi DaiMon: \"Perhaps we can make a deal, yes?\""
            sleep 1
            echo "Options:"
            echo "1) Attempt to trade"
            echo "2) Challenge them to a game of chance"
            echo "3) Try to outsmart them"
            read -p "Choose an action (1-3): " choice
            case $choice in
                1)
                    echo "You attempt to trade with the Ferengi."
                    local trade_outcome=$((RANDOM % 3))
                    if [ $trade_outcome -eq 0 ]; then
                        echo "Ferengi DaiMon: \"A pleasure doing business!\""
                        ((RESOURCES+=5))
                        ((SCORE+=15))
                        echo "You gained 5 resources."
                    elif [ $trade_outcome -eq 1 ]; then
                        echo "Ferengi DaiMon: \"These goods are subpar!\""
                        ((RESOURCES-=2))
                        ((ENERGY-=10))
                        apply_ship_damage
                        echo "The Ferengi swindle you! You lost 2 resources and energy."
                    else
                        echo "The Ferengi attempt to double-cross you!"
                        sleep 1
                        echo "But you anticipated this and outsmart them."
                        ((SCORE+=20))
                        ((MORALE+=5))
                        echo "You successfully gain their resources."
                        ((RESOURCES+=3))
                    fi
                    ;;
                2)
                    echo "You challenge them to a game of chance."
                    sleep 1
                    local game_result=$((RANDOM % 2))
                    if [ $game_result -eq 0 ]; then
                        echo "You win the game!"
                        ((RESOURCES+=5))
                        ((MORALE+=10))
                        echo "Ferengi DaiMon: \"Impossible! You must have cheated!\""
                    else
                        echo "You lose the game."
                        ((RESOURCES-=3))
                        ((MORALE-=5))
                        if [ $RESOURCES -lt 0 ]; then RESOURCES=0; fi
                        echo "Ferengi DaiMon: \"Better luck next time!\""
                    fi
                    ;;
                3)
                    echo "You attempt to outsmart the Ferengi."
                    sleep 1
                    local outsmart=$((RANDOM % 2))
                    if [ $outsmart -eq 0 ]; then
                        echo "You successfully trick the Ferengi into leaving."
                        ((SCORE+=20))
                        ((MORALE+=5))
                    else
                        echo "The Ferengi see through your ruse!"
                        sleep 1
                        echo "They attack your ship!"
                        casualties=$((RANDOM % 40 + 10))
                        ((CREW-=casualties))
                        ((MORALE-=10))
                        apply_ship_damage
                        echo "$casualties crew members lost."
                    fi
                    ;;
                *)
                    echo "Invalid choice. The Ferengi take advantage and steal your resources!"
                    ((RESOURCES-=2))
                    if [ $RESOURCES -lt 0 ]; then RESOURCES=0; fi
                    apply_ship_damage
                    echo "You lost 2 resources."
                    ;;
            esac
            ;;
    esac
    if [ $CREW -le 0 ]; then
        game_over "All crew members have perished!"
    fi
    read -p "Press Enter to continue..."
}

# Encounter anomaly - Mirror Universe
function encounter_anomaly() {
    echo ""
    echo "${BOLD}${MAGENTA}You have encountered a strange spatial anomaly!${RESET}"
    echo "Spock: \"Fascinating. The readings are off the charts, Captain.\""
    sleep 2
    echo "The ship is enveloped by a blinding light..."
    sleep 2
    echo "${BOLD}${RED}You have been transported to the Mirror Universe!${RESET}"
    sleep 2
    # Set a flag to indicate Mirror Universe
    MIRROR_UNIVERSE=true
    # Change the grid symbol to indicate the Mirror Universe
    grid[$E_X,$E_Y]="M"
    # Engage in an encounter with Evil Kirk and Evil Spock
    encounter_mirror_universe
}

# Handle Mirror Universe encounter
function encounter_mirror_universe() {
    echo ""
    echo "${RED}${BOLD}Evil Kirk:${RESET} \"Well, well, what do we have here? An intruder on my turf!\""
    sleep 2
    echo "${RED}${BOLD}Evil Spock:${RESET} \"Captain, their technology could be beneficial to us.\""
    sleep 2
    echo "You realize you must find a way back to your universe."
    sleep 2
    local choice
    echo "Options:"
    echo "1) Attempt to negotiate"
    echo "2) Engage in battle"
    echo "3) Try to escape"
    read -p "Choose an action (1-3): " choice
    case $choice in
        1)
            echo "You attempt to negotiate with Evil Kirk."
            sleep 1
            local negotiation=$((RANDOM % 2))
            if [ $negotiation -eq 0 ]; then
                echo "Evil Kirk: \"Perhaps we can come to an arrangement...\""
                sleep 1
                echo "He agrees to help you return in exchange for resources."
                ((RESOURCES-=5))
                if [ $RESOURCES -lt 0 ]; then RESOURCES=0; fi
                echo "You hand over 5 resources."
                echo "Evil Spock activates the anomaly, and you return home."
                MIRROR_UNIVERSE=false
            else
                echo "Evil Kirk: \"I don't trust you. Seize them!\""
                sleep 1
                echo "A battle ensues!"
                mirror_universe_battle
            fi
            ;;
        2)
            echo "You decide to engage in battle!"
            sleep 1
            mirror_universe_battle
            ;;
        3)
            echo "You attempt to escape back through the anomaly."
            sleep 1
            local escape=$((RANDOM % 2))
            if [ $escape -eq 0 ]; then
                echo "You successfully navigate back through the anomaly!"
                MIRROR_UNIVERSE=false
            else
                echo "Evil Spock: \"Your efforts are illogical.\""
                sleep 1
                echo "They disable your engines!"
                apply_system_damage "Engines" 50
                mirror_universe_battle
            fi
            ;;
        *)
            echo "Invalid choice. Evil Kirk takes advantage of your hesitation!"
            sleep 1
            mirror_universe_battle
            ;;
    esac
    read -p "Press Enter to continue..."
}

# Mirror Universe Battle
function mirror_universe_battle() {
    local battle_outcome=$((RANDOM % 2))
    if [ $battle_outcome -eq 0 ]; then
        echo "Despite the odds, you outsmart Evil Kirk and Spock!"
        ((SCORE+=50))
        ((MORALE+=10))
        echo "You find a way to activate the anomaly and return home."
        MIRROR_UNIVERSE=false
    else
        echo "Evil Spock: \"Your resistance is illogical.\""
        sleep 1
        echo "Your ship takes heavy damage!"
        casualties=$((RANDOM % 200 + 100))
        ((CREW-=casualties))
        ((MORALE-=20))
        apply_ship_damage
        echo "$casualties crew members lost."
        if [ $CREW -le 0 ]; then
            game_over "Your ship has been destroyed by Evil Kirk and Spock!"
        else
            echo "With your remaining strength, you activate the anomaly and escape."
            MIRROR_UNIVERSE=false
        fi
    fi
}

# Apply damage to ship systems randomly
function apply_ship_damage() {
    local systems=("Shields" "Weapons" "Engines" "Life Support" "Sensors")
    local damaged_system=${systems[$((RANDOM % ${#systems[@]}))]}
    local damage_amount=$((RANDOM % 30 + 10))
    apply_system_damage "$damaged_system" "$damage_amount"
}

# Apply damage to a specific ship system
function apply_system_damage() {
    local system=$1
    local damage=$2
    ship_systems[$system]=$((ship_systems[$system] - damage))
    if [ ${ship_systems[$system]} -lt 0 ]; then
        ship_systems[$system]=0
    fi
    echo "${BOLD}${system}${RESET} has been damaged by ${damage} points!"
    # Additional effects based on system damaged
    case $system in
        "Life Support")
            casualties=$((RANDOM % 50 + 10))
            ((CREW-=casualties))
            echo "$casualties crew members lost due to life support failure."
            ;;
        "Engines")
            echo "Ship speed reduced. Energy consumption increased."
            ENERGY=$((ENERGY - 5))
            ;;
        "Shields")
            echo "Shields weakened. Vulnerability to attacks increased."
            ;;
        "Weapons")
            echo "Weapon systems impaired. Combat effectiveness reduced."
            ;;
        "Sensors")
            echo "Sensor array damaged. Navigation and detection impaired."
            ;;
    esac
}

# Move enemies
function move_enemies() {
    local updated_enemies=()
    for key in "${!enemies[@]}"; do
        IFS=',' read -r ex ey <<< "$key"
        local counter=${enemies[$key]}
        ((counter--))
        if [ $counter -le 0 ]; then
            # Remove enemy from current position
            local enemy_type=${grid[$ex,$ey]}
            grid[$ex,$ey]="·"
            unset enemies[$key]

            # Random movement
            local dir=$((RANDOM % 4))
            local new_ex=$ex
            local new_ey=$ey
            case $dir in
                0) ((new_ey--));; # Up
                1) ((new_ey++));; # Down
                2) ((new_ex--));; # Left
                3) ((new_ex++));; # Right
            esac

            # Update grid bounds if necessary
            if [ -z "${grid[$new_ex,$new_ey]}" ]; then
                generate_cell_content $new_ex $new_ey
            fi

            # Check for collision with Enterprise
            if [ $new_ex -eq $E_X ] && [ $new_ey -eq $E_Y ]; then
                encounter_enemy "$enemy_type"
                if [ $CREW -le 0 ]; then
                    game_over "All crew members have perished."
                fi
            else
                # If new position is empty, move enemy
                if [ "${grid[$new_ex,$new_ey]}" == "·" ] || [ "${grid[$new_ex,$new_ey]}" == "P" ]; then
                    grid[$new_ex,$new_ey]=$enemy_type
                    # Reset movement counter
                    enemies[$new_ex,$new_ey]=$((RANDOM % 3 + 1))
                else
                    # If new position occupied, stay in place and reset counter
                    grid[$ex,$ey]=$enemy_type
                    enemies[$ex,$ey]=$((RANDOM % 3 + 1))
                fi
            fi
        else
            # Update counter
            enemies[$key]=$counter
        fi
    done
}

# View crew members and bridge crew
function view_crew() {
    clear
    echo "${BOLD}================== Crew Manifest ==================${RESET}"
    echo "Bridge Crew:"
    for officer in "${BRIDGE_CREW[@]}"; do
        echo "- $officer"
    done
    echo ""
    echo "Total Crew Members: $CREW"
    echo "Morale: $MORALE"
    echo "${BOLD}===================================================${RESET}"
    read -p "Press Enter to return..."
}

# View ship status
function view_ship() {
    clear
    echo "${BOLD}================== Ship Status ===================${RESET}"
    for system in "${!ship_systems[@]}"; do
        health=${ship_systems[$system]}
        if [ $health -gt 75 ]; then
            status="${GREEN}Optimal${RESET}"
        elif [ $health -gt 50 ]; then
            status="${YELLOW}Fair${RESET}"
        elif [ $health -gt 25 ]; then
            status="${MAGENTA}Poor${RESET}"
        else
            status="${RED}Critical${RESET}"
        fi
        echo "$system: $health% - $status"
    done
    echo "${BOLD}===================================================${RESET}"
    read -p "Press Enter to return..."
}

# Game over function
function game_over() {
    echo ""
    echo "${BOLD}GAME OVER!${RESET}"
    echo "$1"
    echo "Final Score: $SCORE"
    exit 0
}

# Exit game
function exit_game() {
    echo ""
    echo "Exiting the game. Live long and prosper! 🖖"
    echo "Final Score: $SCORE"
    exit 0
}

# Main game loop
function main() {
    place_enterprise
    while true; do
        display_grid
        move_enterprise
        move_enemies
    done
}

# Start the game
main
