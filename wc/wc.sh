#!/bin/bash

CACHE_DIR="$HOME/.cache/wc/images"

if [[ "$1" == "-b" ]]; then
    mkdir -p "$CACHE_DIR"
    API_URL="https://wallhaven.cc/api/v1/search?sorting=random&order=desc&categories=111&purity=100&atleast=1920x1080&resolutions=1920x1080,2560x1440,3840x2160&ratios=16x9&topRange=1M&seed=$RANDOM"
    RESPONSE=$(curl -s "$API_URL")
    IMAGE_URL=$(echo "$RESPONSE" | jq -r '.data[0].path')
    if [[ "$IMAGE_URL" != "null" && -n "$IMAGE_URL" ]]; then
        FILENAME="$CACHE_DIR/$(date +%s).jpg"
        curl -s -o "$FILENAME" "$IMAGE_URL"
        if command -v feh >/dev/null; then
            feh --bg-fill "$FILENAME"
        elif command -v nitrogen >/dev/null; then
            nitrogen --set-zoom "$FILENAME"
        elif command -v sxiv >/dev/null; then
            sxiv -g "$FILENAME" && pkill -USR1 sxiv
        else
            echo "no supported wallpaper setter found."
        fi
    else
        echo "failed . ."
    fi
elif [[ "$1" == "-c" ]]; then
    rm -rf "$CACHE_DIR"
    echo "cache cleaned."
elif [[ "$1" == "-s" && -n "$2" ]]; then
    SAVE_DIR="$2"
    mkdir -p "$SAVE_DIR"
    LATEST_FILE=$(ls -t "$CACHE_DIR" | head -n1)
    if [[ -n "$LATEST_FILE" ]]; then
        cp "$CACHE_DIR/$LATEST_FILE" "$SAVE_DIR"
        echo "wallpaper saved to $SAVE_DIR."
    else
        echo "no wallpaper to save."
    fi
else
    echo "usage: $0 -b | -c | -s <directory>"
fi
