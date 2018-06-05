#!/usr/bin/env bash
# z3bra - (c) wtfpl 2014
# Fetch infos on your computer, and print them to stdout every second.
#   Also takes content from window manager to build bar

# ICONS
wifi_icon=''
cpu_icon=''
ram_icon=''
speaker_icon=''
plug_icon=''
thunderbolt_icon=''
clock_icon=''

clock() {
  date=$(date '+%Y-%m-%d %H:%M')
  echo "%{F#FFFFFFFF}$clock_icon $date%{F#FF6A9FB5}"
}

battery() {
    BATC=/sys/class/power_supply/BAT0/capacity

    cap="$(sed -n p $BATC)"
    #green_decimal=$((128 + (128 * $cap) / 101))
    #red_decimal=$((128 + (128 * (100 - $cap)) / 101))
    #red_hex=$(echo "obase=16; $red_decimal" | bc)
    #green_hex=$(echo "obase=16; $green_decimal" | bc)
    #echo "%{F#FF${red_hex}${green_hex}80}$cap%%{F#FF6A9FB5}"
    echo "$cap%%{F#FF6A9FB5}"
}

volume() {
  volume=$(amixer get Master | grep -P -o '\[[0-9]+%\]')
  echo "%{F#FFC2A366}$speaker_icon $volume%{F#FF6A9FB5}"
}

cpuload() {
    LINE=`ps -eo pcpu |grep -vE '^\s*(0.0|%CPU)' |sed -n '1h;$!H;$g;s/\n/ +/gp'`
    cpu=$(bc <<< $LINE)
    echo "%{F#FF94FF70}$cpu_icon $cpu%%{F#FF6A9FB5}"
}

memused() {
  mem=$(free -m | head -n 2 | tail -n 1 | awk '{printf("%2.1fG/%0.2gG\n" ,($3/1024),($2/1024))}')
  echo "%{F#FF80E6FF}$ram_icon $mem%{F#FF6A9FB5}"
}



alsamixer='xdotool key super+F10'
htop='xdotool key super+F9'
# This loop will fill a buffer with our infos, and output it to stdout.
function build_status  {
    buf="%{r}%{F#FF6A9FB5}"
    #buf="${buf} $(cpuload) |"
    #buf="${buf} $(memused) |"
    #buf="${buf} $(volume) |"
    buf="${buf} $(battery) |"
    buf="${buf} $(clock)"

    echo $buf
}

while true; do

  read -t 0.25 new_wm_content
  if [ -n "$new_wm_content" ]; then
    wm_content="$new_wm_content"
  fi

  status_content="$(build_status)"
  combined_content="$wm_content$status_content"

  echo "$combined_content"

  sleep 0.1
done
