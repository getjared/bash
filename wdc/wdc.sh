#!/bin/bash

command -v bc >/dev/null 2>&1 || { echo -e >&2 "\033[0;31mThe script requires 'bc' but it's not installed. Please install it and try again.\033[0m"; exit 1; }

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

C=299792.458

warp_speed() {
    local wf=$1
    if (( $(echo "$wf <= 9" | bc -l) )); then
        echo "$(echo "e((10/3)*l($wf))*$C" | bc -l)"
    else
        echo "$(echo "e($wf)*$C" | bc -l)"
    fi
}

convert_ra() {
    local ra=$1
    hours=$(echo "$ra" | sed -E 's/([0-9]+)h.*/\1/')
    minutes=$(echo "$ra" | sed -E 's/.*h([0-9]+)m.*/\1/')
    seconds=$(echo "$ra" | sed -E 's/.*m([0-9.]+)s.*/\1/')
    echo "$(echo "($hours + $minutes/60 + $seconds/3600) * 15" | bc -l)"
}

convert_dec() {
    local dec=$1
    sign=$(echo "$dec" | grep -o '^[+-]')
    degrees=$(echo "$dec" | sed -E 's/^[+-]?([0-9]+)°.*$/\1/')
    minutes=$(echo "$dec" | sed -E 's/.*°([0-9]+)′.*$/\1/')
    seconds=$(echo "$dec" | sed -E 's/.*′([0-9.]+)″.*$/\1/')
    decimal=$(echo "$degrees + $minutes/60 + $seconds/3600" | bc -l)
    if [ "$sign" == "-" ]; then
        echo "-$decimal"
    else
        echo "$decimal"
    fi
}

read -r -d '' STARS << EOM
Earth|0|0h0m0s|0°0′0″|G2V|1.0|1.0|Our home planet, the third planet from the Sun.|Birthplace of humanity and headquarters of the United Federation of Planets.
Alpha Centauri|4.367|14h39m36.4951s|-60°50′02.308″|G2V|1.1|1.2|Closest star system to the Solar System.|Known as the location of the planet Terra Nova.
Barnard's Star|5.963|17h57m48.499s|+04°41′36.207″|M4Ve|0.144|0.2|A red dwarf star, one of the closest stars to Earth.|Explored in various Star Trek novels.
Sirius|8.611|06h45m08.9173s|-16°42′58.017″|A1V|2.02|1.711|The brightest star in the night sky.|Home to the planet Nausicaa.
Epsilon Eridani|10.522|03h32m55.844s|-09°27′29.74″|K2V|0.82|0.74|A star similar to our Sun, hosts a planetary system.|Associated with the planet Vulcan in some fan theories.
Vega|25.04|18h36m56.33635s|+38°47′01.2802″|A0V|2.135|2.362|One of the brightest stars in the night sky.|Nearby star often mentioned in Star Trek lore.
Betelgeuse|642.5|05h55m10.30536s|+07°24′25.4304″|M1-2Ia-Iab|11.6|887|A red supergiant star nearing the end of its life.|Referenced as part of the Betelgeuse Trade Route.
Proxima Centauri|4.2465|14h29m42.9487s|-62°40′46.141″|M5.5Ve|0.1221|0.1542|The closest star to the Sun, part of the Alpha Centauri system.|Destination of the first Warp 1 flight by Zefram Cochrane.
Rigel|863|05h14m32.27210s|-08°12′05.8981″|B8Ia|21|78.9|A blue supergiant star.|Important location in Star Trek, home to the Rigel system.
Polaris|323|02h31m49.09456s|+89°15′50.7923″|F7Ib|5.4|37.5|The current North Star, a supergiant.|Featured in various episodes and novels.
Altair|16.73|19h50m46.9985s|+08°52′05.956″|A7V|1.79|1.63|A bright star in the constellation Aquila.|Home to Altair IV, visited in Star Trek.
Vulcan|16.5|12h30m49.42338s|+12°23′28.0439″|K-class|0.81|0.76|Hypothetical location near 40 Eridani A.|Homeworld of the Vulcans, Spock's species.
Qo'noS|112|19h59m28.3566s|+14°38′22.789″|M-class|N/A|N/A|Approximate location in the Beta Quadrant.|Homeworld of the Klingon Empire.
Romulus|159|02h49m15s|+89°15′50.8″|K-class|N/A|N/A|Approximate location near Beta Reticuli.|Homeworld of the Romulan Star Empire.
Bajor|52|17h47m00s|+35°0′0″|K5V|N/A|N/A|Approximate location in the Alpha Quadrant.|Homeworld of the Bajorans and location of Deep Space Nine.
EOM

IFS=$'\n' read -rd '' -a STARS_ARRAY <<< "$STARS"

read -r -d '' SHIPS << EOM
USS Enterprise-D|Galaxy|9.6|Flagship of the Federation in the 24th century.
USS Voyager|Intrepid|9.975|Lost in the Delta Quadrant, took 70 years to return at maximum warp.
USS Defiant|Defiant|9.5|A warship designed to combat the Borg.
USS Enterprise|Constitution|8|The original starship Enterprise.
USS Discovery|Crossfield|9.7|Equipped with experimental spore drive.
EOM

IFS=$'\n' read -rd '' -a SHIPS_ARRAY <<< "$SHIPS"

display_stars() {
    echo -e "${BOLD}${CYAN}Available Stars and Planets:${RESET}"
    local index=1
    for star in "${STARS_ARRAY[@]}"; do
        local name=$(echo "$star" | cut -d'|' -f1)
        echo -e "  ${YELLOW}[${index}]${RESET} ${GREEN}$name${RESET}"
        ((index++))
    done
}

display_ships() {
    echo -e "${BOLD}${CYAN}Available Starships:${RESET}"
    local index=1
    for ship in "${SHIPS_ARRAY[@]}"; do
        local name=$(echo "$ship" | cut -d'|' -f1)
        echo -e "  ${YELLOW}[${index}]${RESET} ${GREEN}$name${RESET}"
        ((index++))
    done
}

get_star_data() {
    local index=$1
    echo "${STARS_ARRAY[$((index - 1))]}"
}

get_ship_data() {
    local index=$1
    echo "${SHIPS_ARRAY[$((index - 1))]}"
}

echo -e "${BOLD}${MAGENTA}Welcome to the Warp Drive Calculator!${RESET}"
echo -e "${CYAN}This tool calculates hypothetical warp travel times between star systems using real astronomical data.${RESET}"
echo ""
echo -e "${BOLD}${MAGENTA}Mission Briefing:${RESET}"
echo -e "${CYAN}You are tasked with navigating a starship between two points in the galaxy. Choose your vessel and set your course!${RESET}"
echo ""

display_ships
echo ""
read -p "$(echo -e "${BOLD}Select your starship by number:${RESET} ")" ship_index
ship=$(get_ship_data "$ship_index")
ship_name=$(echo "$ship" | cut -d'|' -f1)
ship_class=$(echo "$ship" | cut -d'|' -f2)
ship_max_warp=$(echo "$ship" | cut -d'|' -f3)
ship_notes=$(echo "$ship" | cut -d'|' -f4)

echo ""
display_stars
echo ""
read -p "$(echo -e "${BOLD}Select your origin star by number:${RESET} ")" origin_index
origin_star=$(get_star_data "$origin_index")
origin_name=$(echo "$origin_star" | cut -d'|' -f1)
origin_distance=$(echo "$origin_star" | cut -d'|' -f2)
origin_ra_sex=$(echo "$origin_star" | cut -d'|' -f3)
origin_dec_sex=$(echo "$origin_star" | cut -d'|' -f4)
origin_spectral=$(echo "$origin_star" | cut -d'|' -f5)
origin_mass=$(echo "$origin_star" | cut -d'|' -f6)
origin_radius=$(echo "$origin_star" | cut -d'|' -f7)
origin_fact=$(echo "$origin_star" | cut -d'|' -f8)
origin_lore=$(echo "$origin_star" | cut -d'|' -f9)

echo ""
display_stars
echo ""
read -p "$(echo -e "${BOLD}Select your destination star by number:${RESET} ")" dest_index
dest_star=$(get_star_data "$dest_index")
dest_name=$(echo "$dest_star" | cut -d'|' -f1)
dest_distance=$(echo "$dest_star" | cut -d'|' -f2)
dest_ra_sex=$(echo "$dest_star" | cut -d'|' -f3)
dest_dec_sex=$(echo "$dest_star" | cut -d'|' -f4)
dest_spectral=$(echo "$dest_star" | cut -d'|' -f5)
dest_mass=$(echo "$dest_star" | cut -d'|' -f6)
dest_radius=$(echo "$dest_star" | cut -d'|' -f7)
dest_fact=$(echo "$dest_star" | cut -d'|' -f8)
dest_lore=$(echo "$dest_star" | cut -d'|' -f9)

origin_ra=$(convert_ra "$origin_ra_sex")
origin_dec=$(convert_dec "$origin_dec_sex")
dest_ra=$(convert_ra "$dest_ra_sex")
dest_dec=$(convert_dec "$dest_dec_sex")

deg2rad=$(echo "scale=10; 4*a(1)/180" | bc -l)
origin_ra_rad=$(echo "$origin_ra * $deg2rad" | bc -l)
origin_dec_rad=$(echo "$origin_dec * $deg2rad" | bc -l)
dest_ra_rad=$(echo "$dest_ra * $deg2rad" | bc -l)
dest_dec_rad=$(echo "$dest_dec * $deg2rad" | bc -l)

cos_angle=$(echo "
scale=10;
odr = $origin_dec_rad;
ddr = $dest_dec_rad;
orr = $origin_ra_rad;
drr = $dest_ra_rad;
cos_angle = s(odr)*s(ddr) + c(odr)*c(ddr)*c(orr - drr);
cos_angle
" | bc -l)

cos_angle=$(echo "$cos_angle" | awk '{if ($1 > 1) print 1; else if ($1 < -1) print -1; else print $1}')

pi=$(echo "scale=10; 4*a(1)" | bc -l)

angle_rad=$(echo "
scale=10;
define arccos(x) {
  if (x == 1) return 0;
  if (x == -1) return $pi;
  if (x > -1 && x < 1) {
    return a(sqrt(1 - x*x)/x);
  }
}
arccos($cos_angle)
" | bc -l)

distance=$(echo "
scale=10;
d1 = $origin_distance;
d2 = $dest_distance;
angle = $angle_rad;
distance = sqrt(d1^2 + d2^2 - 2*d1*d2*c(angle));
distance
" | bc -l)

LY_TO_KM=9460730472580.8
distance_km=$(echo "$distance * $LY_TO_KM" | bc -l)

echo ""
echo -e "${BOLD}Maximum Warp Factor for $ship_name (${ship_class} class): ${ship_max_warp}${RESET}"
read -p "$(echo -e "${BOLD}Enter warp factor (up to maximum warp):${RESET} ")" warp_factor

if ! [[ "$warp_factor" =~ ^[0-9]*\.?[0-9]+$ ]] || (( $(echo "$warp_factor > $ship_max_warp" | bc -l) )); then
    echo -e "${RED}Invalid warp factor. Please enter a numeric value up to the ship's maximum warp factor.${RESET}"
    exit 1
fi

speed_km_s=$(warp_speed "$warp_factor")

travel_time_s=$(echo "$distance_km / $speed_km_s" | bc -l)

travel_time_yr=$(echo "$travel_time_s / (31557600)" | bc -l)
travel_time_day=$(echo "$travel_time_s / 86400" | bc -l)
travel_time_hr=$(echo "$travel_time_s / 3600" | bc -l)

echo ""
echo -e "${BOLD}${MAGENTA}Mission Summary:${RESET}"
echo -e "${BOLD}${GREEN}Starship:${RESET} $ship_name (${ship_class} class)"
echo -e "  ${CYAN}Maximum Warp:${RESET} $ship_max_warp"
echo -e "  ${CYAN}Notes:${RESET} $ship_notes"
echo ""
echo -e "${BOLD}${MAGENTA}Calculating travel time from $origin_name to $dest_name at Warp $warp_factor...${RESET}"
echo -e "${BLUE}------------------------------------------------------------${RESET}"
echo -e "${BOLD}${GREEN}Origin Star: $origin_name${RESET}"
echo -e "  ${CYAN}Distance from Earth:${RESET} $origin_distance light-years"
echo -e "  ${CYAN}Right Ascension:${RESET} $origin_ra_sex"
echo -e "  ${CYAN}Declination:${RESET} $origin_dec_sex"
echo -e "  ${CYAN}Spectral Type:${RESET} $origin_spectral"
echo -e "  ${CYAN}Mass:${RESET} $origin_mass Solar Masses"
echo -e "  ${CYAN}Radius:${RESET} $origin_radius Solar Radii"
echo -e "  ${CYAN}Astronomical Facts:${RESET} $origin_fact"
echo -e "  ${CYAN}Star Trek Lore:${RESET} $origin_lore"
echo ""
echo -e "${BOLD}${GREEN}Destination Star: $dest_name${RESET}"
echo -e "  ${CYAN}Distance from Earth:${RESET} $dest_distance light-years"
echo -e "  ${CYAN}Right Ascension:${RESET} $dest_ra_sex"
echo -e "  ${CYAN}Declination:${RESET} $dest_dec_sex"
echo -e "  ${CYAN}Spectral Type:${RESET} $dest_spectral"
echo -e "  ${CYAN}Mass:${RESET} $dest_mass Solar Masses"
echo -e "  ${CYAN}Radius:${RESET} $dest_radius Solar Radii"
echo -e "  ${CYAN}Astronomical Facts:${RESET} $dest_fact"
echo -e "  ${CYAN}Star Trek Lore:${RESET} $dest_lore"
echo ""
echo -e "${BOLD}${YELLOW}Angular Separation:${RESET} $(echo "($angle_rad / $deg2rad)" | bc -l) degrees"
echo -e "${BOLD}${YELLOW}Distance between stars:${RESET} $(printf "%.4f" $distance) light-years"
echo -e "${BOLD}${YELLOW}Distance in kilometers:${RESET} $(printf "%.2e" $distance_km) km"
echo -e "${BOLD}${YELLOW}Warp Factor:${RESET} $warp_factor"
echo -e "${BOLD}${YELLOW}Warp Speed:${RESET} $(printf "%.2e" $speed_km_s) km/s"
echo ""
echo -e "${BOLD}${MAGENTA}Estimated Travel Time:${RESET}"
if (( $(echo "$travel_time_yr >= 1" | bc -l) )); then
    echo -e "  ${BOLD}$(printf "%.2f" $travel_time_yr)${RESET} years"
elif (( $(echo "$travel_time_day >= 1" | bc -l) )); then
    echo -e "  ${BOLD}$(printf "%.2f" $travel_time_day)${RESET} days"
else
    echo -e "  ${BOLD}$(printf "%.2f" $travel_time_hr)${RESET} hours"
fi
echo -e "${BLUE}------------------------------------------------------------${RESET}"
echo -e "${CYAN}Note:${RESET} This calculation uses the Star Trek: The Next Generation warp speed scale."
echo -e "For warp factors above 9, speeds increase exponentially toward Warp 10, which is infinite velocity."
echo ""
echo -e "${BOLD}${MAGENTA}Additional Information:${RESET}"
echo -e "  - ${YELLOW}Speed of Light:${RESET} $C km/s"
echo -e "  - ${YELLOW}1 Light-Year:${RESET} $LY_TO_KM km"
echo -e "  - ${YELLOW}Warp Speed Formula:${RESET} Based on the TNG Technical Manual"
echo -e "  - ${YELLOW}Spectral Types${RESET} indicate the star's temperature and color."
echo -e "  - ${YELLOW}Solar Masses and Radii${RESET} are relative to our Sun."
