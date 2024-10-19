#!/bin/bash

if [[ "$1" == "--b" ]]; then
    CACHE_DIR="$HOME/.cache/wc/images"
    mkdir -p "$CACHE_DIR"

    # get a random wallpaper
    API_URL="https://wallhaven.cc/api/v1/search?sorting=random&order=desc&categories=111&purity=100&atleast=1920x1080&resolutions=1920x1080,2560x1440,3840x2160&ratios=16x9&topRange=1M&seed=$RANDOM"
    RESPONSE=$(curl -s "$API_URL")

    # extract the image URL using jq
    IMAGE_URL=$(echo "$RESPONSE" | jq -r '.data[0].path')

    if [[ "$IMAGE_URL" != "null" && -n "$IMAGE_URL" ]]; then
        FILENAME="$CACHE_DIR/$(date +%s).jpg"
        curl -s -o "$FILENAME" "$IMAGE_URL"
        feh --bg-fill "$FILENAME"
    else
        echo "failed to get image. ."
    fi
else
    echo "use me: $0 --b"
fi
