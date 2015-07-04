#!/bin/sh
CONNECTED_ENABLED_MONITORS=$(xrandr -q | awk '/ connected [^(]/ {print $3}')

for V_OUT in $CONNECTED_ENABLED_MONITORS
do
  echo $V_OUT
  arr=$(echo $V_OUT | tr "+" "\n")
  dimensions=${arr[0]}
  x="${arr[1]}"
  y="${arr[2]}"
  echo "dimensions $dimensions"

  arr2=$(echo $dimensions | tr "x" "\n")
  width="${arr2[0]}"
  height="${arr2[1]}"

  echo "x: $x y: $y"
  echo "width: $width height: $height"
done
