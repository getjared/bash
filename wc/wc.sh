#!/bin/bash

CACHE_DIR="$HOME/.cache/wc/images"

usage() {
    echo "Usage:"
    echo "  $0 -b [-nsfw]       Set a random wallpaper. Use -nsfw to allow NSFW content."
    echo "  $0 -c               Clean the wallpaper cache."
    echo "  $0 -s <directory>   Save the latest wallpaper to the specified directory."
    exit 1
}

SET_BG=false
CLEAN_CACHE=false
SAVE=false
SAVE_DIR=""
ALLOW_NSFW=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b)
            SET_BG=true
            shift
            ;;
        -c)
            CLEAN_CACHE=true
            shift
            ;;
        -s)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                SAVE=true
                SAVE_DIR="$2"
                shift 2
            else
                echo "Error: -s requires a directory argument."
                usage
            fi
            ;;
        -nsfw)
            ALLOW_NSFW=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ "$SET_BG" == true ]]; then
    mkdir -p "$CACHE_DIR"

    if [[ "$ALLOW_NSFW" == true ]]; then
        PURITY="111"  # Allows SFW, Sketchy, and NSFW
    else
        PURITY="100"  # Allows only SFW
    fi

    API_URL="https://wallhaven.cc/api/v1/search?sorting=random&order=desc&categories=111&purity=${PURITY}&atleast=1920x1080&resolutions=1920x1080,2560x1440,3840x2160&ratios=16x9&topRange=1M&seed=$RANDOM"

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
            echo "No supported wallpaper setter found."
        fi
    else
        echo "Failed to retrieve wallpaper."
    fi
fi

if [[ "$CLEAN_CACHE" == true ]]; then
    rm -rf "$CACHE_DIR"
    echo "Cache cleaned."
fi

if [[ "$SAVE" == true ]]; then
    if [[ -z "$SAVE_DIR" ]]; then
        echo "Error: Save directory not specified."
        usage
    fi

    mkdir -p "$SAVE_DIR"
    LATEST_FILE=$(ls -t "$CACHE_DIR" | head -n1)

    if [[ -n "$LATEST_FILE" ]]; then
        cp "$CACHE_DIR/$LATEST_FILE" "$SAVE_DIR"
        echo "Wallpaper saved to $SAVE_DIR."
    else
        echo "No wallpaper to save."
    fi
fi

if [[ "$SET_BG" == false && "$CLEAN_CACHE" == false && "$SAVE" == false ]]; then
    usage
fi
