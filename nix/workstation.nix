{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    letsencrypt                      # Auto SSL Cert
  ];

  networking = {
    hostName = "campfire"; # Define your hostname.
    hostId = "87813f15";
  };

  services.openssh = {
    enable = true;
    ports = [ 25980 ];
    passwordAuthentication = true;
  };

  users.users.alex.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnQusENKbsEzR4o8Sbrs3gkZVNWhBxS9b16vWIs75q47k+/tMZ0OgL541OSgGEIxKsvf0kUYpG9q/sAQNoRcb1pUw23HmfgFs+w7whcQK0HudjW3/f8js3eI/dka+6/Q7cxe0P/X/+P31PwXAHJcmN0/aARTyEITmCufm6mcyO/aCDBpKoDy0YK9f+nbpRBnybgDVp3ac8Wbqtd8c6NJjtmLHWNAtl6jthejf0NJoXGvrIHbawogVtHBAD4vUXUOt1kZjUrR+AItOT49JlzJCjR/3qYFC+Ce8VNYa7TOHQourgPNHJ2vlhz6a4QFUNyN7FcdfK/qfQYOpDN4JqcsO1mCkZvR78LcDZG4Mqt3DQK04Xaip75PfSKdLz/joP4zkey5Lp9656ForGcUWfjYxXtODWx/5+2rEvQncprcRUJNh8mDRMWK/LaVBICFPTsMJ/lzLYShMdpUtlEEwPHDwURqzXXPbaTeaJsqARr/Kmk4l/ghaa+R5upoqID+jURb9MrX7fMdv3PSe9mq7wpUJzZ81cY2WKJ1l8KiS15nhEenThAJwRB9uFuJhuRWeP8qqUv6zKq28LmcbGAApNF9SbvzMWPrsSwS4vlolDuZOoau41V+4ETkbVuazmGOmgQfdWIR8LKHybWbv3gnxdOSJXC0GQ56apnz1XnJDSMr8uxw== acmcarther@gmail.com"
  ];
}
