#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

for cmd in jq bc curl date; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: The '$cmd' utility is required but not installed.${NC}"
        echo "Install it using your package manager. For Arch Linux:"
        echo "  sudo pacman -S $cmd"
        exit 1
    fi
done

get_iss_status() {
    ISS_API="http://api.open-notify.org/iss-now.json"
    ISS_DATA=$(curl -s "$ISS_API")

    if [ $? -ne 0 ] || [ -z "$ISS_DATA" ]; then
        echo -e "${RED}ISS: Unable to retrieve position data.${NC}"
        return
    fi

    LAT=$(echo "$ISS_DATA" | jq -r '.iss_position.latitude')
    LON=$(echo "$ISS_DATA" | jq -r '.iss_position.longitude')
    TIMESTAMP=$(echo "$ISS_DATA" | jq -r '.timestamp')
    DATETIME=$(date -d @"$TIMESTAMP" +"%Y-%m-%d %H:%M:%S")
    ALTITUDE=420
    VELOCITY=7.66

    if [ -z "$LAT" ] || [ -z "$LON" ]; then
        echo -e "${RED}ISS: Incomplete position data received.${NC}"
        return
    fi

    echo -e "${GREEN}🛰️  ISS Status:${NC}"
    echo -e "  • Position: Latitude $LAT°, Longitude $LON°"
    echo -e "  • Altitude: $ALTITUDE km"
    echo -e "  • Velocity: $VELOCITY km/s"
    echo -e "  • Last Updated: $DATETIME"
    echo ""
}

calculate_distance() {
    local launch_date=$1
    local speed_km_s=$2

    CURRENT_DATE_SEC=$(date +%s)
    LAUNCH_DATE_SEC=$(date -d "$launch_date" +%s)
    ELAPSED_SEC=$((CURRENT_DATE_SEC - LAUNCH_DATE_SEC))
    DISTANCE_KM=$(echo "scale=2; $ELAPSED_SEC * $speed_km_s" | bc)
    DISTANCE_AU=$(echo "scale=6; $DISTANCE_KM / 149597870.7" | bc)

    DISTANCE_KM_FMT=$(printf "%'0.2f" "$DISTANCE_KM")
    DISTANCE_AU_FMT=$(printf "%'.6f" "$DISTANCE_AU")

    echo "$DISTANCE_AU_FMT AU ($DISTANCE_KM_FMT km)"
}

get_voyager1_status() {
    LAUNCH_DATE="1977-09-05"
    SPEED_KM_S=17.0
    DISTANCE=$(calculate_distance "$LAUNCH_DATE" "$SPEED_KM_S")
    DISTANCE_AU=$(echo "$DISTANCE" | awk '{print $1}')
    DISTANCE_KM=$(echo "$DISTANCE" | awk '{print $3}' | tr -d ',')

    echo -e "${YELLOW}🚀 Voyager 1 Status:${NC}"
    echo -e "  • Launch Date: $LAUNCH_DATE"
    echo -e "  • Average Speed: $SPEED_KM_S km/s"
    echo -e "  • Distance from Earth: $DISTANCE_AU AU ($DISTANCE_KM km)"
    echo ""
}

get_voyager2_status() {
    LAUNCH_DATE="1977-08-20"
    SPEED_KM_S=15.4
    DISTANCE=$(calculate_distance "$LAUNCH_DATE" "$SPEED_KM_S")
    DISTANCE_AU=$(echo "$DISTANCE" | awk '{print $1}')
    DISTANCE_KM=$(echo "$DISTANCE" | awk '{print $3}' | tr -d ',')

    echo -e "${YELLOW}🚀 Voyager 2 Status:${NC}"
    echo -e "  • Launch Date: $LAUNCH_DATE"
    echo -e "  • Average Speed: $SPEED_KM_S km/s"
    echo -e "  • Distance from Earth: $DISTANCE_AU AU ($DISTANCE_KM km)"
    echo ""
}

get_new_horizons_status() {
    LAUNCH_DATE="2006-01-19"
    SPEED_KM_S=16.26
    DISTANCE=$(calculate_distance "$LAUNCH_DATE" "$SPEED_KM_S")
    DISTANCE_AU=$(echo "$DISTANCE" | awk '{print $1}')
    DISTANCE_KM=$(echo "$DISTANCE" | awk '{print $3}' | tr -d ',')

    echo -e "${YELLOW}🚀 New Horizons Status:${NC}"
    echo -e "  • Launch Date: $LAUNCH_DATE"
    echo -e "  • Average Speed: $SPEED_KM_S km/s"
    echo -e "  • Distance from Earth: $DISTANCE_AU AU ($DISTANCE_KM km)"
    echo ""
}

get_curiosity_status() {
    API_KEY="DEMO"
    ROVER_API="https://api.nasa.gov/mars-photos/api/v1/manifests/Curiosity?api_key=$API_KEY"
    ROVER_DATA=$(curl -s "$ROVER_API")

    if [ $? -ne 0 ] || [ -z "$ROVER_DATA" ]; then
        echo -e "${RED}Curiosity: Unable to retrieve status data.${NC}"
        return
    fi

    STATUS=$(echo "$ROVER_DATA" | jq -r '.photo_manifest.status')
    LANDING_DATE=$(echo "$ROVER_DATA" | jq -r '.photo_manifest.landing_date')
    MAX_SOL=$(echo "$ROVER_DATA" | jq -r '.photo_manifest.max_sol')
    TOTAL_PHOTOS=$(echo "$ROVER_DATA" | jq -r '.photo_manifest.total_photos')

    if [ -z "$STATUS" ] || [ -z "$LANDING_DATE" ] || [ -z "$MAX_SOL" ]; then
        echo -e "${RED}Curiosity: Incomplete status data received.${NC}"
        return
    fi

    echo -e "${GREEN}🤖 Curiosity Rover Status:${NC}"
    echo -e "  • Mission Status: $STATUS"
    echo -e "  • Landing Date: $LANDING_DATE"
    echo -e "  • Current Martian Sol: $MAX_SOL"
    echo -e "  • Total Photos Taken: $TOTAL_PHOTOS"
    echo ""
}

get_jwst_status() {
    LAUNCH_DATE="2021-12-25"
    SPEED_KM_S=0.0

    DISTANCE_KM=1500000
    DISTANCE_AU=$(echo "scale=6; $DISTANCE_KM / 149597870.7" | bc)
    DISTANCE_AU_FMT=$(printf "%'.6f" "$DISTANCE_AU")

    echo -e "${YELLOW}🔭 James Webb Space Telescope Status:${NC}"
    echo -e "  • Launch Date: $LAUNCH_DATE"
    echo -e "  • Average Speed: Maintains position at L2"
    echo -e "  • Distance from Earth: $DISTANCE_AU_FMT AU ($DISTANCE_KM km)"
    echo ""
}

main() {
    echo -e "${CYAN}🖖 Spacecraft Tracker 🖖${NC}"
    echo "---------------------------------"
    get_iss_status
    get_voyager1_status
    get_voyager2_status
    get_new_horizons_status
    get_jwst_status
    get_curiosity_status
    echo "---------------------------------"
}

main
