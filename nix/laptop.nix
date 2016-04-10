{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bumblebee                          # GFX device multiplexing
  ];

  # Enable bumblebee gpu management
  hardware.bumblebee.enable = true;

  networking = {
    hostName = "bbq"; # Define your hostname.
    hostId = "87813f15";
  };

  services.xserver.synaptics = {
    accelFactor = "0.05";
    enable = true;
    maxSpeed = "20";
    twoFingerScroll = true;
    additionalOptions = ''
      MatchProduct "ETPS"
      Option "TouchpadOff"  "1"
      Option "FingerLow" "3"
      Option "FingerHigh" "5"
      Option "FingerPress" "30"
      Option "MaxTapTime" "100"
      Option "MaxDoubleTapTime" "150"
      Option "TapButton1" "1"
      Option "TapButton2" "2"
      Option "TapButton3" "3"
      Option "FastTaps" "1"
      Option "VertTwoFingerScroll" "1"
      Option "HorizTwoFingerScroll" "1"
      Option "TrackstickspeedSpeed" "0"
      Option "LTCornerButton" "3"
      Option "LBCornerButton" "2"
      Option "CoastingFriction" "20"
      Option "PalmDetect" "1"
      Option "PalmMinWidth" "10"
      Option "PalmMinZ" "255"
      Option "ClickPad" "true"
      Option "EmulateMidButtonTime" "0"
    '';
  };
}
