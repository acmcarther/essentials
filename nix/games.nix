{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    playonlinux                        # Wine DirectX/Syscall
    steam                              # Games
    teamspeak_client                   # Team voice chat
  ];

  # Enable direct rendering for 32 bit applications
  #   Required to run steam games on 64 bit system
  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
  };
}
