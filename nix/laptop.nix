{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bumblebee                          # GFX device multiplexing
    tlp                                # Power management
  ];

  # Enable bumblebee gpu management
  hardware.bumblebee.enable = true;

  networking = {
    hostName = "bbq"; # Define your hostname.
    hostId = "87813f15";
  };

  services.openssh = {
    enable = true;
    ports = [ 25980 ];
    passwordAuthentication = true;
  };

  services.tlp.enable = true;

  users.users.guest.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeAwUk2YzfYOKuCNTCVDwOwfhXOVNL3naAjYwkF3asUYZh+DTJK7h0ekYRMVq8R8EwK9BltTCXvCuZRDNAf7oaZEGvJJRHIVhkSb5q+VkZHZV/e/nGPTXMK7MKip6GjjoS6t6W43QFygf3ndHMVZTod8ykcQYWyorgFPJqtCjuBpzjY2JxblKkIf3y5p/JC+O7DCbc5sRiVtnJmdY6bsUw+AU7iGB979jaVkrhH9LpZnh4fuHqdwnVXvdl53FgeehX5+cs2LfpLFDx4fjjvN6YNaH4vBNesQnbhgIF+W2GmPS4z7JfFyyvcOqznD+EyEvijfApCvO3F2gWnp7GRmj/RrMU8NuZq1RX3XTD+RrMJUBZW/hnxIDZTv5QOyQiFnuR1BOk0MXa5rPYJx8yDXxw1zojI8cPSZxRnRq3OcDDV9ebLDl8sGMik+iSXU8/afpHGF5kVDAV9VRzU6+nFLcDRBUJwONaAKQlFdl6lIL5Fc8HGc3/g4KSvX6VLhnQ+rHhAgZZ3sKsdJfFbD5qTTVQPsyOBYe5tlBact1qC1fylqbSKwxQPORjnYtlsRXrWXJIatdN5MwfUNC8YK2oEEZb61j7wPVK73KKlWrVuPkifufbpfqHH51I54WZXZcVpgtmZUvnEkPoCbEq15cPrDNQKjsXJ/XZL1lx3fKA5gN+Cw== acmcarther@gmail.com"
  ];

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
