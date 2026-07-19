#!/usr/bin/env bash

# Cumulus Wi-Fi Menu
# Requires: nmcli, rofi

THEME="$HOME/.config/rofi/type-2/wifi.rasi"

# Toggle menu if already open
pgrep -x rofi >/dev/null && {
    pkill rofi
    exit 0
}

wifi_state=$(nmcli radio wifi)

if [[ "$wifi_state" == "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
else
    toggle="󰖩  Enable Wi-Fi"
fi

menu="$toggle\n󰐥  Manual Connection"

while IFS=: read -r active ssid signal security; do

    [[ -z "$ssid" ]] && continue

    if (( signal >= 80 )); then
        icon="󰤨"
    elif (( signal >= 60 )); then
        icon="󰤥"
    elif (( signal >= 40 )); then
        icon="󰤢"
    elif (( signal >= 20 )); then
        icon="󰤟"
    else
        icon="󰤯"
    fi

    lock=""
    [[ -n "$security" ]] && lock=" 󰌾"

    connected=""
    [[ "$active" == "yes" ]] && connected="   Connected"

    menu+="\n$icon  $ssid$connected$lock"

done < <(
    nmcli -t -f ACTIVE,SSID,SIGNAL,SECURITY device wifi list
)

choice=$(echo -e "$menu" | rofi \
    -dmenu \
    -i \
    -p "Wi-Fi" \
    -theme "$THEME"
)

[[ -z "$choice" ]] && exit

case "$choice" in

    "󰖪  Disable Wi-Fi")
        nmcli radio wifi off
        exit
        ;;

    "󰖩  Enable Wi-Fi")
        nmcli radio wifi on
        exit
        ;;

    "󰐥  Manual Connection")

        ssid=$(rofi \
            -dmenu \
            -theme "$THEME" \
            -p "SSID")

        [[ -z "$ssid" ]] && exit

        pass=$(rofi \
            -dmenu \
            -password \
            -theme "$THEME" \
            -p "Password")

        if [[ -z "$pass" ]]; then
            nmcli dev wifi connect "$ssid"
        else
            nmcli dev wifi connect "$ssid" password "$pass"
        fi

        exit
        ;;

esac

ssid=$(echo "$choice" | sed -E 's/^󰤨 |^󰤥 |^󰤢 |^󰤟 |^󰤯 //' | sed 's/   Connected//' | sed 's/ 󰌾//')

known=$(nmcli -t -f NAME connection show | grep -Fx "$ssid")

if [[ -n "$known" ]]; then
    nmcli connection up "$ssid"
else

    pass=$(rofi \
        -dmenu \
        -password \
        -theme "$THEME" \
        -p "Password (leave blank if open)")

    if [[ -z "$pass" ]]; then
        nmcli dev wifi connect "$ssid"
    else
        nmcli dev wifi connect "$ssid" password "$pass"
    fi

fi