if [[ $1 == "removedl" ]]
then
  xrandr --output eDP1 --auto --pos 0x0
  xrandr --output DP1 --right-of eDP1 --auto
  xrandr --output DP2 --right-of DP1 --auto
  xrandr --output HDMI3 --right-of eDP1 --auto
else
  xrandr --output eDP1 --auto --pos 0x0
  xrandr --output DP1 --right-of eDP1 --auto
  xrandr --output DP2 --right-of DP1 --auto
  xrandr --output HDMI3 --right-of eDP1 --auto
fi
