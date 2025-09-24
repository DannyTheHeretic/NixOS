{
  inputs,
  outputs,
  pkgs,
  username,
  options,
  browser,
  terminal,
  locale,
  timezone,
  kbdLayout,
  kbdVariant,
  consoleKeymap,
  self,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.nix-index
  ];

  programs.nix-index-database.comma.enable = true;

  users.users.theheretic = {
    isNormalUser = true;
    uid = 1000;
    #subuids = [ { start = 100000; count = 65536; } ];
    #subgids = [ { start = 100000; count = 65536; } ];
    subUidRanges = [ { startUid = 100000; count = 65536; } ];
    subGidRanges = [ { startGid = 100000; count = 65536; } ];

    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      "input"
      "disk"
      "libvirtd"
      "video"
      "audio"
    ];
  };
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.${username} = {pkgs, ...}: {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      xdg.enable = true;
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ];
        xdgOpenUsePortal = true;
      };
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "23.11"; # Please read the comment before changing.
      home.sessionVariables = {
        EDITOR = "nano";
        BROWSER = browser;
        TERMINAL = terminal;
      };

      home.packages = with pkgs; [
        # Applications
        #kate
        firefox
        plexamp
	      zip
        (pkgs.buildFHSEnv {
              name = "uv";
              runScript = "uv";
              targetPkgs = pkgs: with pkgs; [  uv ];
        })
        (pkgs.buildFHSEnv {
              name = "pixi";
              runScript = "pixi";
              targetPkgs = pkgs: with pkgs; [ pixi ];
        })
	      (pkgs.buildFHSEnv {
              name = "python";
              runScript = "python3";
              targetPkgs = pkgs: with pkgs; [     
		    python313
		    python313Packages.pip
		    python313Packages.virtualenv 
	      ];
        })
        immich-go
        wget
        libreoffice-qt
        hunspell
        hunspellDicts.en_US
        curl
        glib
        plex-desktop
        #plex-desktop-1.108.1
        podman-compose
        gcc
        openssl
        go
        slack
        obsidian
        easyeffects
        fzf
        fd
        git
        chromium
        gh
        htop
        libjxl
        microfetch
        nix-prefetch-scripts
        ripgrep
        tldr
        unzip
        openrgb-with-all-plugins
        # L2TP/IPsec VPN packages
        networkmanager-l2tp
        strongswan
      ];
    };
  };

  # L2TP/IPsec VPN Configuration
  services.xl2tpd.enable = true;
  services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.secrets"
    ];
  };

  # Network Manager L2TP plugin
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-l2tp
    ];
  };

  # StrongSwan configuration to fix integrity test failure
  environment.etc."strongswan.conf" = {
    text = ''
      charon {
        integrity_test = no
      }
    '';
    mode = "0644";
  };

  # IPsec configuration file  
  environment.etc."ipsec.conf" = {
    text = ''
      config setup
        charondebug="ike 1, knl 1, cfg 0"
        uniqueids=no
      
      conn L2TP-PSK
        authby=secret
        pfs=no
        auto=add
        keyingtries=3
        rekey=no
        ikelifetime=8h
        keylife=1h
        type=transport
        left=%defaultroute
        leftfirewall=yes
        leftprotoport=17/1701
        right=%any
        rightprotoport=17/%any
    '';
    mode = "0644";
  };

  # IPsec secrets file
  environment.etc."ipsec.secrets" = {
    text = ''
      # IPsec secrets for L2TP/IPsec VPN
      %any %any : PSK "recall-victory-over-acronyms"
    '';
    mode = "0600";
  };
  
  environment.etc."ipsec.d/.keep" = {
    text = "";
  };
  
  # Prevent the circular include issue by creating an empty nm-l2tp secrets file
  environment.etc."ipsec.d/ipsec.nm-l2tp.secrets" = {
    text = "";
    mode = "0600";
  };

  # Create required certificate directories
  system.activationScripts.ipsecDirs = ''
    mkdir -p /etc/ipsec.d/{cacerts,aacerts,ocspcerts,acerts,crls}
    chmod 755 /etc/ipsec.d/{cacerts,aacerts,ocspcerts,acerts,crls}
  '';



  # Kernel modules needed for L2TP/IPsec
  boot.kernelModules = [
    "l2tp_ppp"
    "l2tp_netlink"
    "l2tp_core"
    "l2tp_ip"
    "ppp_generic"
    "ppp_async"
    "ppp_mppe"
  ];

  # Alternative approach: Use strongswan-minimal instead of full strongswan
  environment.systemPackages = with pkgs; [
    vscodium
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
            mkhl.direnv
            #jeanp413.open-remote-ssh
            bbenoist.nix
            arrterian.nix-env-selector
	          github.vscode-github-actions
            yzhang.markdown-all-in-one
            # asvetliakov.vscode-neovim
            # vscodevim.vim
            tamasfe.even-better-toml
            jnoortheen.nix-ide
            # redhat.vscode-yaml
            # vadimcn.vscode-lldb
            rust-lang.rust-analyzer
            ms-vscode.cpptools
            ms-vscode.cmake-tools
            ms-vscode.makefile-tools
            ziglang.vscode-zig
            # ms-dotnettools.csharp
            # python
            ms-python.python
            njpwerner.autodocstring
            ms-python.debugpy
            charliermarsh.ruff
            wholroyd.jinja
            samuelcolvin.jinjahtml
            batisteo.vscode-django
            usernamehw.errorlens
            # JavaScript
            # esbenp.prettier-vscode
            # ms-python.pylint
      	    enkia.tokyo-night
          ]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
              name = "remote-ssh-edit";
              publisher = "ms-vscode-remote";
              version = "0.47.2";
              sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      	  }
          {
              name = "remote-server";
              publisher	= "ms-vscode";
              version = "1.6.2025091709";
              sha256 = "1v322paf8fkzns0c4zqy7yz97apyf9kdbzq7rx3h9mxcisbm5kby";
          }
    	];
  })
    prismlauncher
    killall
    lm_sensors
    jq
    bibata-cursors
    sddm-astronaut # Overlayed
    pokego # Overlayed
    noisetorch
    pkgs.kdePackages.qtsvg
    gnumake
    pkgs.kdePackages.qtmultimedia
    glib
    pkgs.kdePackages.qtvirtualkeyboard
    fcitx5-mozc-ut
    tailscale
    pkgs.qt6Packages.qtwayland
    pkgs.qt6Packages.full
    devbox
    # L2TP/IPsec related packages
    xl2tpd
    strongswan
    networkmanager-l2tp
    ppp
    # Additional debugging tools
    tcpdump
    wireshark-cli
  ];

  # Firewall configuration for L2TP/IPsec
  networking.firewall = {
    allowedUDPPorts = [ 500 4500 1701 ];
    allowedTCPPorts = [ ];
    # Enable connection tracking helpers
    connectionTrackingModules = [ "l2tp" "pptp" ];
  };

  # Filesystems support
  boot.supportedFilesystems = ["ntfs" "exfat" "ext4" "fat32" "btrfs"];
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.hardware.openrgb.enable = true;
  services.xserver = {
    enable = true;

    exportConfiguration = true; # Make sure /etc/X11/xkb is populated so localectl works correctly
    xkb = {
      layout = kbdLayout;
      variant = kbdVariant;
    };
  }; 
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_lavd"; # https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
  };

  # Bootloader.
  boot = {
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_zen; # _latest, _zen, _xanmod_latest, _hardened, _rt, _OTHER_CHANNEL, etc.
    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 2; # Display bootloader indefinitely until user selects OS
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        gfxmodeEfi = "2715x1527"; # for 4k: 3840x2160
        gfxmodeBios = "2715x1527"; # for 4k: 3840x2160
        theme = pkgs.stdenv.mkDerivation {
          pname = "distro-grub-themes";
          version = "3.1";
          src = pkgs.fetchFromGitHub {
            owner = "AdisonCavani";
            repo = "distro-grub-themes";
            rev = "v3.1";
            hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
          };
          installPhase = "cp -r customize/nixos $out";
        };
      };
    };
  };

  time.timeZone = timezone;
  i18n.defaultLocale = locale;
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ 
      # fcitx5-mozc
      fcitx5-mozc-ut
      fcitx5-gtk 
    ];
  };

  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = locale;
  };
  console.keyMap = consoleKeymap; # Configure console keymap

  security = {
    polkit.enable = true;
    #sudo.wheelNeedsPassword = false;
  };

  programs.dconf.enable = true;

  # Enable bluetooth
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

 

  # Enable sddm login manager
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      settings.Theme.CursorTheme = "Bibata-Modern-Classic";
      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
      ];
    };
  };

  # Setup keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
          bluetooth.autoswitch-to-headset-profile = false
        '')
      ];
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  fonts.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
    fira-code
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      # allowUnfreePredicate = _: true;
    };
  };

  programs.appimage.binfmt=true;
  programs.appimage.enable=true;

  environment.sessionVariables = {
    # These are the defaults, and xdg.enable does set them, but due to load
    # order, they're not set before environment.variables are set, which could
    # cause race conditions.
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";

    templates = "${self}/dev-shells";
  };
  services.tailscale.enable = true;

  programs.npm.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  
  services.openssh = {
    enable = true;
    ports  = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      #UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  programs = {
    nh = {
      enable = true;
      # Automatic garbage collection
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
      flake = "/home/${username}/NixOS";
    };
  };
  nix = {
    # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true; # May make rebuilds longer but less size
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
        "https://chaotic-nyx.cachix.org/"
        "https://cachix.cachix.org"
        "https://nix-gaming.cachix.org/"
        "https://hyprland.cachix.org"
        # "https://nixpkgs-wayland.cachix.org"
        # "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = false;
      warn-dirty = false;
      keep-outputs = true;
      keep-derivations = true;
    };
    optimise.automatic = true;
    package = pkgs.nixVersions.latest;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
