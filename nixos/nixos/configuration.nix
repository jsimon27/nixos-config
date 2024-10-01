# This is your system's configuration file.guest.draganddrop = true
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features =  "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Sound settings
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  # Enable CUPS
  services.printing.enable = true;

  # Terminal keyboard layout
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,caps:escape";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Enable libinput
  services.libinput.enable = true;

  # SDDM
  services.displayManager.sddm = {
    package = pkgs.lib.mkForce pkgs.libsForQt5.sddm;
    extraPackages = pkgs.lib.mkForce [
      pkgs.libsForQt5.qt5.qtbase
      pkgs.libsForQt5.qt5.qtdeclarative
      pkgs.libsForQt5.qt5.qtquickcontrols
      pkgs.libsForQt5.qt5.qtmultimedia
      pkgs.libsForQt5.qt5.qtgraphicaleffects
    ];
    enable = true;
    settings = {
      Theme = {
        Current="sddm-lain-wired-theme";
        ThemeDir="/usr/share/sddm/themes/";
      };
    };
  };

  # Networking
  networking.hostName = "chateau-dlf";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  boot = {
  kernelModules = [ "kvm-intel" "wl" ];
  extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.grub.device = "nodev";
  };
  #timezone 
  time.timeZone = "America/New_York";

  #xserver
  services.xserver.enable = true;

  # hyprland DE
  programs.hyprland.enable = true;
    programs.thunar.enable = true;

  # vbox
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "jssim" ];

  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.draganddrop = true;

  fonts.packages = with pkgs; [
    nerdfonts

  ];

  environment.systemPackages = with pkgs; [
      # Sys packages
    vim
    neovim
    wget
    cmake
    tree
    git
    pass
    gnome.gnome-keyring
    libsecret

      # Audio
    wireplumber
    easyeffects
    calf
    lsp-plugins
    zam-plugins
    mda_lv2

    # Langs, compilers and libraries
    gcc
    nodejs
    python39
    python39Packages.pandas
    python39Packages.beautifulsoup4
    python39Packages.requests
    python312Packages.pygame

    # Container project stuff
    docker
    kubernetes

    # AWS
    awscli2
    awsrm
    awsls
    awsume
    awsbck
    awstats
    awslogs
    aws-mfa
    aws-env
    aws-gate
    aws-c-io
    aws-vault

    # Hyprland
    nwg-panel
    hyprdim
    rofi-wayland
    dunst
    hyprpaper
    wluma
    wlsunset
    brightnessctl
    wl-clipboard
    flameshot
    hyprkeys
    kitty
    kitty-themes
    selectdefaultapplication

    # Utils
    ffmpeg-full
    unzip
    imgp
    imv
    yt-dlp
    imagemagick
    ntfs3g
    wineWowPackages.staging
    wineWowPackages.waylandFull
    acpi

    # Security Utils / games
    nmap
    age
    sshs
    libsecret
    openvpn
    htb-toolkit
    checkpwn
    termshark
    portal
    
    # CLI's
    fastfetch
    ytfzf
    ani-cli
    devtodo
    yazi
    cmus
    peaclock
    cmatrix
    atac
    bitwarden-cli
    manga-cli
    typer

    # Apps
    newsboat
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH

    librewolf
    calibre
    anki
    obsidian
    
  ];

  users.users = {
    # FIXME: Replace with your username
    jssim = {
      isNormalUser = true;
    # openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    # ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "networkmanager" "audio" "docker"];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
