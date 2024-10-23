#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

declare -A JUTSU_PATTERNS
declare -A JUTSU_JAPANESE

JUTSU_PATTERNS=(
    ["rasengan"]="🌀💫✨💥💫"
    ["chidori"]="⚡️⚡️🌩️✨💥"
    ["fireball"]="🔥👄💨🔥🔥"
    ["shadowclone"]="🥷🥷🥷🥷🥷"
    ["gale"]="🙏🏼🚬💨🫦🔥"
    ["waterdragon"]="🌊🐉💧💦💫"
    ["sandtomb"]="🏜️💨⏳🌪️💀"
    ["mindtransfer"]="🧠💫👻💭🎯"
    ["healing"]="💚✨🩹💫💖"
    ["sharingan"]="👁️💫🌀🔴✨"
    ["amaterasu"]="👁️🩸🔥⚫️💀"
    ["woodstyle"]="🌳🌲🌱🍃💨"
    ["expansion"]="💪💨↗️👊💥"
    ["lightning"]="⚡️🌩️💥⚡️💫"
    ["windstyle"]="💨🌪️🍃💫✨"
    ["tsukuyomi"]="🌙👁️😱💫🌀"
    ["susanoo"]="⚔️👹🛡️💜💫"
    ["mudwall"]="🤲🏼🪨🧱🏔️💪"
    ["substitute"]="💨🪵💭🥷✨"
    ["shintenshin"]="💫🧠👻💭↪️"
    ["multiclone"]="🥷✨🥷✨🥷"
    ["rashenshuriken"]="🌀⭐️💫🌪️💥"
    ["chibaku"]="🌍💫⚫️🌑💥"
    ["kirin"]="⚡️🐉☈💥⚡️"
    ["sandstorm"]="🏜️🌪️💨💀🏃"
    ["eightgates"]="🙅🏻‍♂️🧍🏻‍♂️🔥🦵🏼💪🏼🔥💀"
    ["kotoamatsukami"]=$'👁️  ⭐️  👁️\n💫  🧠  💫\n🌀  ✨  🌀'
    ["explodingpalm"]=$'👊  💥  💫\n💥  🔥  💥\n💫  💥  👊'
    ["particlebeam"]=$'⚛️  →  →  →  ⚡️\n→  ⚛️  →  ⚡️  →\n→  →  ⚛️  →  💥'
    ["paperdance"]=$'📜  📜  📜\n💫  🥷  💫\n📜  📜  📜'
    ["lavastyle"]=$'🌋  🔥  🌋\n🔥  🌊  🔥\n🌋  🔥  🌋'
    ["crystalice"]=$'❄️  💎  ❄️\n💎  🌨️  💎\n❄️  💎  ❄️'
    ["infinitytsukuyomi"]=$'🌕\n↓\n👁️  👁️  👁️\n💫  🌍  💫\n✨  ✨  ✨'
    ["truthseekingballs"]=$'⚫️    ⚫️    ⚫️\n  ↘️  ⚫️  ↙️\n⚫️  🥷  ⚫️\n  ↗️  ⚫️  ↖️\n⚫️    ⚫️    ⚫️'
    ["summoning"]=$'🌀  🌀  🌀\n🌀  💨  🌀\n🌀  🩸  🌀\n↓   ↓   ↓\n🐸  🐍  🐌'
    ["sageart"]=$'🍃  🧘  🍃\n💫  ⭐️  💫\n🌟  🔮  🌟'
    ["sandburrial"]=$'⏳  ⏳  ⏳  ⏳  ⏳\n⏳  💀  💀  💀  ⏳\n⏳  ⏳  ⏳  ⏳  ⏳\n  ↓   ↓   ↓\n🏜️  🏜️  🏜️'
    ["mindscape"]=$'💭  💭  💭\n💭  🧠  💭\n💭  ➡️  🎯\n  💫   💫\n  👻   😱'
    ["poisoncloud"]=$'☠️  ☠️  ☠️\n💭  💭  💭\n💨  🤢  💨\n☠️  ☠️  ☠️'
    ["papersea"]=$'📜  📜  📜  📜\n📜  🌊  🌊  📜\n📜  🌊  🌊  📜\n📜  📜  📜  📜'
    ["boneprison"]=$'🦴  🦴  🦴\n🦴  😱  🦴\n🦴  🦴  🦴\n  ↑   ↑\n💀  💀'
    ["butterflydance"]=$'🦋        🦋\n   ↘️    ↙️\n🦋   🥷   🦋\n   ↗️    ↖️\n🦋        🦋'
    ["ashkilling"]=$'💨  💨  💨\n🦴  🦴  🦴\n💀  🔥  💀\n⚱️  ⚱️  ⚱️'
    ["needlehell"]=$'💉  💉  💉\n↓   ↓   ↓\n💉  😱  💉\n↓   ↓   ↓\n💉  💉  💉'
    ["bloodprison"]=$'🩸  🩸  🩸  🩸\n🩸  😨  😨  🩸\n🩸  😨  😨  🩸\n🩸  🩸  🩸  🩸'
    ["explosivespiders"]=$'🕷️  🕷️  🕷️\n🕷️  💣  🕷️\n🕷️  🕷️  🕷️\n↓   ↓   ↓\n💥  💥  💥'
    ["frogchoir"]=$'🐸  🎵  🐸\n🎵  🐸  🎵\n🐸  🎵  🐸\n💫  💫  💫'
    ["mangekyo"]=$'↗️  👁️  ↖️\n👁️  🔴  👁️\n↘️  👁️  ↙️\n  💫   💫\n  🩸   🩸'
    ["sagesixpaths"]=$'⭐️  ⭐️  ⭐️\n🌟  👁️  🌟\n🔮  🧘  🔮\n✨  ✨  ✨'
    ["scorchedearth"]=$'🔥  🔥  🔥\n🔥  🌍  🔥\n🔥  🔥  🔥\n💨  💨  💨\n⚱️  ⚱️  ⚱️'
    ["waterprison"]=$'💧  💧  💧\n💧  😱  💧\n💧  💧  💧\n🌊  🌊  🌊'
    ["puppetmaster"]=$'🎭    🎭    🎭\n  ↘️  🕴️  ↙️\n🎭  🪄  🎭\n  ↗️  🎭  ↖️\n🎭    🎭    🎭'
    ["mindforest"]=$'🌳  🌳  🌳  🌳\n🌳  👁️  👁️  🌳\n🌳  🧠  🌳  🌳\n🌳  🌳  🌳  🌳'
    ["demonwind"]=$'👹  💨  💨\n💨  🌪️  💨\n💨  💨  👹\n⚔️  ⚔️  ⚔️'
    ["thunderstorm"]=$'⛈️  ⛈️  ⛈️\n↓   ↓   ↓\n⚡️  🌩️  ⚡️\n↓   ↓   ↓\n💥  💥  💥'
    ["voidgate"]=$'⚫️  ⚫️  ⚫️\n⚫️  🌀  ⚫️\n⚫️  ⚫️  ⚫️\n  →   ←\n💫  ✨  💫'
    ["phoenixflame"]=$'🦅  🔥  🦅\n🔥  🌟  🔥\n🦅  🔥  🦅\n✨  ✨  ✨'
    ["dimensionalrift"]=$'🌀  🌌  🌀\n🌌  👁️  🌌\n🌀  🌌  🌀\n↙️  ↓   ↘️'
    ["darkabyss"]=$'⚫️  ⚫️  ⚫️\n⚫️  👻  ⚫️\n⚫️  ⚫️  ⚫️\n👻  👻  👻'
    ["moonlight"]=$'🌕    🌕    🌕\n  🌙  🌙  🌙\n    🌑    \n  ⭐️  ⭐️  ⭐️\n✨    ✨    ✨'
)

JUTSU_JAPANESE=(
    ["rasengan"]="Rasengan (らせんがん)"
    ["chidori"]="Chidori (千鳥)"
    ["fireball"]="Katon: Gōkakyū no Jutsu (火遁・豪火球の術)"
    ["shadowclone"]="Kage Bunshin no Jutsu (影分身の術)"
    ["gale"]="Fūton: Daitoppa (風遁・大突破)"
    ["waterdragon"]="Suiton: Suiryūdan no Jutsu (水遁・水龍弾の術)"
    ["sandtomb"]="Sabaku Kyū (砂縛柩)"
    ["mindtransfer"]="Shintenshin no Jutsu (心転身の術)"
    ["healing"]="Shōsen Jutsu (掌仙術)"
    ["sharingan"]="Sharingan (写輪眼)"
    ["amaterasu"]="Amaterasu (天照)"
    ["woodstyle"]="Mokuton (木遁)"
    ["expansion"]="Baika no Jutsu (倍化の術)"
    ["lightning"]="Raiton (雷遁)"
    ["windstyle"]="Fūton (風遁)"
    ["tsukuyomi"]="Tsukuyomi (月読)"
    ["susanoo"]="Susanoo (須佐能乎)"
    ["mudwall"]="Doton: Doryūheki (土遁・土流壁)"
    ["substitute"]="Kawarimi no Jutsu (換分身の術)"
    ["shintenshin"]="Shintenshin no Jutsu (心転身の術)"
    ["multiclone"]="Tajū Kage Bunshin no Jutsu (多重影分身の術)"
    ["rashenshuriken"]="Fūton: Rasenshuriken (風遁・螺旋手裏剣)"
    ["chibaku"]="Chibaku Tensei (地爆天星)"
    ["kirin"]="Kirin (麒麟)"
    ["sandstorm"]="Ryūsa Bakuryū (流砂爆流)"
    ["eightgates"]="Hachimon Tonkō no Jin: Shimon (八門遁甲の陣: 死門)"
    ["kotoamatsukami"]="Kotoamatsukami (別天神)"
    ["explodingpalm"]="Bakuhatsu no Te (爆発の手)"
    ["particlebeam"]="Ryūshi no Hikari (粒子の光)"
    ["paperdance"]="Kami no Mai (紙の舞)"
    ["lavastyle"]="Yōton (溶遁)"
    ["crystalice"]="Hyōton: Kesshō (氷遁・結晶)"
    ["infinitytsukuyomi"]="Mugen Tsukuyomi (無限月読)"
    ["truthseekingballs"]="Gudōdama (求道玉)"
    ["summoning"]="Kuchiyose no Jutsu (口寄せの術)"
    ["sageart"]="Sennin Mōdo (仙人モード)"
    ["sandburrial"]="Sabaku Sōsō (砂漠送葬)"
    ["mindscape"]="Shinranshin no Jutsu (心乱身の術)"
    ["poisoncloud"]="Doku Kumo no Jutsu (毒雲の術)"
    ["papersea"]="Kami no Umi (紙の海)"
    ["boneprison"]="Sawarabi no Mai (椎骨の舞)"
    ["butterflydance"]="Chō no Mai (蝶の舞)"
    ["ashkilling"]="Hai no Jutsu (灰の術)"
    ["needlehell"]="Hari Jigoku (針地獄)"
    ["bloodprison"]="Chiketsu Rō (血結牢)"
    ["explosivespiders"]="Bakuhatsu Kumo (爆発蜘蛛)"
    ["frogchoir"]="Gamaguchi Shibari (蝦蟇口縛)"
    ["mangekyo"]="Mangekyō Sharingan (万華鏡写輪眼)"
    ["sagesixpaths"]="Rikudō Sennin Mōdo (六道仙人モード)"
    ["scorchedearth"]="Karyū Endan (火龍炎弾)"
    ["waterprison"]="Suirō no Jutsu (水牢の術)"
    ["puppetmaster"]="Akahigi: Hyakki no Sōen (赤秘技・百機の操演)"
    ["mindforest"]="Mori no Shinryaku (森の侵略)"
    ["demonwind"]="Akuma no Kaze (悪魔の風)"
    ["thunderstorm"]="Raiu no Arashi (雷雨の嵐)"
    ["voidgate"]="Kūmon (空門)"
    ["phoenixflame"]="Hōō no Honō (鳳凰の炎)"
    ["dimensionalrift"]="Jigen no Kiretsu (次元の亀裂)"
    ["darkabyss"]="Yami no Shin'en (闇の深淵)"
    ["moonlight"]="Tsuki no Hikari (月の光)"
)

echo -e "${YELLOW}"
cat << "EOF"
═══════════════════════════════
   ████████╗███████╗██████╗ ███╗   ███╗     ██╗██╗   ██╗████████╗███████╗██╗   ██╗
   ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║     ██║██║   ██║╚══██╔══╝██╔════╝██║   ██║
      ██║   █████╗  ██████╔╝██╔████╔██║     ██║██║   ██║   ██║   ███████╗██║   ██║
      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██   ██║██║   ██║   ██║   ╚════██║██║   ██║
      ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚█████╔╝╚██████╔╝   ██║   ███████║╚██████╔╝
      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚════╝  ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝ 
═══════════════════════════════
EOF
echo -e "${NC}"

show_jutsus() {
    echo -e "${GREEN}Available Jutsus:${NC}"
    for jutsu in "${!JUTSU_PATTERNS[@]}"; do
        echo -e "${CYAN}• $jutsu${NC} - ${PURPLE}${JUTSU_JAPANESE[$jutsu]}${NC}"
    done
}

perform_jutsu() {
    local input=$1
    local jutsu_pattern=${JUTSU_PATTERNS[$input]}
    local jutsu_japanese=${JUTSU_JAPANESE[$input]}
    
    if [ -n "$jutsu_pattern" ]; then
        echo -e "${BLUE}Performing $input jutsu...${NC}"
        echo -e "${PURPLE}$jutsu_japanese${NC}"
        sleep 0.5
        echo -e "手 (Preparing hand signs)..."
        sleep 0.5
        echo -e "${RED}$jutsu_pattern${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    else
        echo -e "${RED}Unknown jutsu! Try one of these:${NC}"
        show_jutsus
    fi
}

while true; do
    echo -e "${YELLOW}Enter your jutsu (or 'list' for available jutsus, 'exit' to quit):${NC}"
    read -r input

    case $input in
        "exit")
            echo "さようなら (Sayonara)! 👋"
            exit 0
            ;;
        "list")
            show_jutsus
            ;;
        *)
            perform_jutsu "$input"
            ;;
    esac
done
