{ config, lib, pkgs, ... }:
let
  home_directory = builtins.getEnv "HOME";
  current_user = builtins.getEnv "USER";
  logdir = "${home_directory}/Library/Logs";
  tmuxPlugins = with pkgs.tmuxPlugins; [
    logging
    fpp
    yank
    open
    copycat
  ];
  sources = import ../nix/sources.nix;
in
{
  system.defaults = import ./darwin/defaults.nix;
  networking = {
    #dns = [ "127.0.0.1" ];
    #search = [ "local" ] ++ work_dns.domains or [];
    knownNetworkServices = [
      "Wi-Fi"
    ];
  };
  launchd.daemons = {};
  launchd.user.agents = {};
  system.activationScripts.postActivation.text = ''
    chflags nohidden ${home_directory}/Library
    sudo launchctl load -w \
        /System/Library/LaunchDaemons/com.apple.atrun.plist > /dev/null 2>&1 \
        || exit 0
  '';
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowUnsupportedSystem = false;
      permittedInsecurePackages = [
        "openssl-1.0.2u"
      ];
    };
    overlays = let
      path = ../overlays;
    in
      with builtins;
      map (
        n:
          import (path + ("/" + n))
      ) (
        filter (
          n:
            match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))
        ) (attrNames (readDir path))
      ) ++ [
        (import ./envs.nix)
      ];
  };
  environment = {
    systemPackages = import ./packages.nix {
      inherit pkgs;
    };
    profiles =
      [
        "$HOME/.nix-profile"
        "/run/current-system/sw"
        "/nix/var/nix/profiles/default"
      ];
    systemPath = [
      "${home_directory}/bin"
      "${pkgs.Docker}/Applications/Docker.app/Contents/Resources/bin"
      "/usr/local/bin"
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ];
    variables = {
      HOME_MANAGER_CONFIG = "${home_directory}/src/dotnix/config/home.nix";
      MANPATH = [
        "${home_directory}/.nix-profile/share/man"
        "${home_directory}/.nix-profile/man"
        "${config.system.path}/share/man"
        "${config.system.path}/man"
        "/usr/local/share/man"
        "/usr/share/man"
        "/Developer/usr/share/man"
        "/usr/X11/man"
      ];
      LC_CTYPE = "en_US.UTF-8";
      LESSCHARSET = "utf-8";
      LEDGER_COLOR = "true";
      PAGER = "less";
      TERM = "xterm-256color";
    };
    shellAliases = {
      rehash = "hash -r";
    };
    pathsToLink = [
      "/info"
      "/etc"
      "/share"
      "/include"
      "/lib"
      "/libexec"
    ];
    extraOutputsToInstall = [
      "man"
    ];
    etc."tmux-gruvbox-dark.conf".source = ../files/tmux-gruvbox-dark.conf;
    etc."tmux-srcery".source = ../files/srcery-tmux;
  };
  services = {
    nix-daemon.enable = false;
    activate-system.enable = true;
  };

  nix = {
    package = pkgs.nixStable;
    trustedUsers = [
      "root"
      "jackhenahan"
      "JHENAHAN"
      "@admin"
      "@wheel"
    ];
    maxJobs = 10;
    buildCores = 8;
    gc.user = current_user;
    gc.automatic = true;
    gc.options = "--max-freed \$((25 * 1024**3 - 1024 * \$(df -P -k /nix/store | tail -n 1 | awk '{ print \$4 }')))";
    distributedBuilds = false;
    binaryCaches = [
      https://cache.nixos.org
      https://nix-tools.cachix.org
      https://hercules-ci.cachix.org
      https://hydra.iohk.io
      https://cache.dhall-lang.org
      https://dhall.cachix.org
    ];
    binaryCachePublicKeys = [
      cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
      nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A=
      hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0=
      hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=
      cache.dhall-lang.org:I9/H18WHd60olG5GsIjolp7CtepSgJmM2CsO813VTmM=
      dhall.cachix.org-1:8laGciue2JBwD49ICFtg+cIF8ddDaW7OFBjDb/dHEAo=
    ];
    #extraOptions = ''
    #  auto-optimise-store = true
    #'';
  };
  users.nix.configureBuildUsers = true;
  users.nix.nrBuildUsers = 32;
  programs.bash.enable = true;
  programs.fish = {
    enable = true;
    vendor.config.enable = true;
    vendor.completions.enable = true;
    vendor.functions.enable = true;
  };
  programs.tmux = {
    enable = true;
    enableMouse = true;
    enableFzf = true;
    enableVim = true;
    enableSensible = true;
    defaultCommand = "${pkgs.fish}/bin/fish --login";
    tmuxConfig = ''
      set -g @srcery_tmux_patched_font '1'
      run -b /etc/tmux-srcery/srcery.tmux
      ${lib.concatStrings (map (x: "run-shell ${x.rtp}\n") tmuxPlugins)}
    '';
  };
  programs.nix-index.enable = true;
  system.stateVersion = 3;
}
