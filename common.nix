{ pkgs, ...}:
let

in {
  nixpkgs.overlays = [ (import ./overlays.nix) ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.ntp.enable = true;
  networking.timeServers = [
    "0.ch.pool.ntp.org"
    "1.ch.pool.ntp.org"
    "2.ch.pool.ntp.org"
    "3.ch.pool.ntp.org"
  ];
  time.timeZone = "Europe/Zurich";

  services.nixosManual.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "prohibit-password";
  services.openssh.passwordAuthentication = false;

  ## osquery-2.5.2 is marked as broken
  #services.osquery.enable = true;

  services.logrotate.enable = true;
  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
      #enabledCollectors = [];
    };
  };

  # Maybe incompatible with some provisioner (i.e. <google-compute-config>)
  #users.mutableUsers = false;
  
  users.motd = "Restricted Access Only";

  programs.tmux.enable = true;
  programs.tmux.clock24 = true;
  programs.mosh.enable = true;

  users.extraGroups = {
    admin = { };
  };
  users.users.admin = {
    isNormalUser = true;
    createHome = true;
    home = "/home/admin";
    group = "admin";
    extraGroups = [ "wheel" "docker" ];
    password = "Chang3m3";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkb3IO5IHWuhmT4NhQqHvChQNGbNL9bcPekD7X67MQPv+s839JbB2XrI8fXvlkDDxDwa+aofFuO3b54WqkYPXb8ShJ9qIcSDfETwsPPS/jLjOEj7f6OGkvPg9k5VYsXyb+8aKhRgeid4y0NLpuVwz6q8W3wocIWg5HS3zKpSGpG2W5+zSvVlsWBfxQfNSt+9REpyYmgAN4qJpMvfQNH2zBb3QkK/cDXEXG2hCK7v/AH09fR0D5BlwllVHxfUDoiQV18njGDlW2PgqY/xukI/LO/JOp84GJM4WpqWxsrkYl3ovY22BEJ+kuSNRIbR0za2/6y27bcE2MZP0ob691B+cT"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkb3IO5IHWuhmT4NhQqHvChQNGbNL9bcPekD7X67MQPv+s839JbB2XrI8fXvlkDDxDwa+aofFuO3b54WqkYPXb8ShJ9qIcSDfETwsPPS/jLjOEj7f6OGkvPg9k5VYsXyb+8aKhRgeid4y0NLpuVwz6q8W3wocIWg5HS3zKpSGpG2W5+zSvVlsWBfxQfNSt+9REpyYmgAN4qJpMvfQNH2zBb3QkK/cDXEXG2hCK7v/AH09fR0D5BlwllVHxfUDoiQV18njGDlW2PgqY/xukI/LO/JOp84GJM4WpqWxsrkYl3ovY22BEJ+kuSNRIbR0za2/6y27bcE2MZP0ob691B+cT"
    ];
  };

  environment.systemPackages = with pkgs; [
    dnsutils inetutils htop ncat ngrep tcpdump
    #osquery
  ];

  networking.firewall.logRefusedConnections = false;

}