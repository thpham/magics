{ config, pkgs, ... }:

let
  configNetworkDongle = pkgs.writeScript "configNetworkDongle.sh" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.coreutils}/bin/sleep 2
    ${pkgs.systemd}/bin/systemctl start modem-manager
    ${pkgs.coreutils}/bin/sleep 2
    ${pkgs.modemmanager}/bin/mmcli -S
    ${pkgs.modemmanager}/bin/mmcli -m 0 -e
    ${pkgs.coreutils}/bin/sleep 2
    # mmcli -m 0 --simple-connect="pin=0000,apn=swisscom-test.m2m.ch"
    # mmcli -i 0 --pin=0000 --disable-pin
    ${pkgs.modemmanager}/bin/mmcli -m 0 --simple-connect="apn=swisscom-test.m2m.ch"
    ${pkgs.coreutils}/bin/sleep 30
    ${pkgs.systemd}/bin/systemctl start zerotierone
  '';

  polkitConf = ''
    polkit.addRule(function(action, subject) {
      if (
        action.id.indexOf("org.freedesktop.ModemManager") == 0
        )
      { return polkit.Result.YES; }
    });
  '';

in {
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = ["cma=128M" "console=ttyS1,115200n8" "console=ttyAMA0,115200n8" "console=tty0" ];
  boot.kernelModules = [ "snd_bcm2835" ];
  boot.cleanTmpDir = true;
  #boot.plymouth = {
  #  enable = true;
  #  logo = pkgs.fetchurl {
  #    url = "https://nixos.org/logo/nixos-hires.png";
  #    sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
  #  };
  #};

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
     name = "broadcom-rpi3-extra";
     srcs = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/927fa8e/brcm/brcmfmac43430-sdio.txt";
        sha256 = "1c70i06m2azhx7wf6iiyxg0d2n6rcndm6n6pisanyh3jrvapmkp4";
      })
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/86e88fb/brcm/brcmfmac43430-sdio.bin";
        sha256 = "1xgsnh22z7vqhhzb4fzx96j07zrhfsssq5m5by2s73nvrgvpwswr";
      })
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/RPi-Distro/bluez-firmware/09eeca3/broadcom/BCM43430A1.hcd";
        sha256 = "0c499j0zn5sq71l1mgnk4fnndbbdcq4xag2gbcbvd76k0f80pmwd";
      })
     ];
     phases = [ "installPhase" ];
     installPhase = ''
      mkdir -p $out/lib/firmware/brcm
      for src in $srcs
        do
          name=`stripHash $src`
          cp $src $out/lib/firmware/brcm/$name
        done
     '';
     })
  ];
  networking.wireless.enable = false;
  networking.wireless.networks = {
    iThings = {
      psk = "";
    };
  };
  networking.hostName = "rpi3";

  networking.firewall = {
    trustedInterfaces = [ "zt0" ];
    allowedTCPPorts = [
      22   # ssh
      4317 # pulseaudio sink
    ];
  };

  services.udev = {
    extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="14fe", RUN+="${pkgs.usb_modeswitch}/bin/usb_modeswitch -J -v 12d1 -p 14fe"
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="0c:5b:8f:27:9a:64", RUN+="${configNetworkDongle} 2> /var/log/networkDongle.err.log"
    '';
  };
  systemd.packages = with pkgs; [ modemmanager ];
  services.dbus.packages = with pkgs; [ modemmanager ];
  services.udev.packages = with pkgs; [ modemmanager ];
  security.polkit.extraConfig = polkitConf;
  
  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  services.nixosManual.enable = false;
  services.ntp.enable = true;
  time.timeZone = "Europe/Zurich";

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  services.zerotierone.enable = true;
  programs.mosh.enable = true;
  #programs.java.enable = true;
  #programs.java.package = pkgs.oraclejdk;

  environment.systemPackages = with pkgs; [
    #raspberrypi-tools
    coreutils dnsutils nettools usbutils pciutils
    htop conky ncat ngrep tcpdump lsof feh glxinfo
    i2c-tools lm_sensors dtc
    alsaUtils alsaPlugins mpg123 pamix
    usb-modeswitch usb-modeswitch-data modemmanager
    electron nodejs-8_x flite
  ];

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

  virtualisation.docker.enable = true;

  services.xserver = {
    enable = false; # true
    layout = "ch";
    xkbVariant = "fr";
    videoDrivers = [ "modesetting" ];
    modules = [ ];
    resolutions = [ { x = 1920; y = 1080; } ];
    serverLayoutSection = ''
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime"     "0"
      Option "BlankTime"   "0"
    '';
    displayManager.slim = {
      enable = true;
      defaultUser = "admin";
      autoLogin = true;
      #theme = pkgs.fetchurl {
      #  url = "https://github.com/rnhmjoj/nix-slim/archive/0.3.0.tar.gz";
      #  sha256 = "0qhha3pggh444s5ba4kcgdxv6d2fmrc7cvvii44c779vinb5wis6";
      #};
    };
    windowManager.openbox = {
      enable = true;
    };
    #desktopManager.lxqt = {
    #  enable = true;
    #};
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    #extraPackages = with pkgs; [ ];
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true;
    tcp = {
      enable = true;
      anonymousClients.allowAll = true;
      #anonymousClients.allowedIpRanges = [ "127.0.0.1" "192.168.55.0/24" "172.22.0.0/16" ];
    };
    zeroconf.publish.enable = true;
    #extraConfig = ''
    #'';
  };
  #sound.extraConfig = ''
  #'';

  hardware.bluetooth = {
    enable = true;
    extraConfig = ''
      [General]
      ControllerMode = bredr
    '';
  };

  system.stateVersion = "unstable";
  nixpkgs.config.allowUnfree = true;
}