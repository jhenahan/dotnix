{ config, lib, pkgs, ... }:
let
  home_directory = builtins.getEnv "HOME";
  logdir = "${home_directory}/Library/Logs";
  home_dns = import ../private/home/dns.nix;
  work_dns = import ../private/work/dns.nix;
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
    hostName = "noether";
    #dns = [ "127.0.0.1" ];
    #search = [ "local" ] ++ work_dns.domains or [];
    knownNetworkServices = [
      "Wi-Fi"
    ];
  };
  launchd.daemons = {
    nix-daemon.environment.OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES";
    #pdnsd = {
    #  script = ''
    #    cp -pL /etc/pdnsd.conf /tmp/.pdnsd.conf
    #    chmod 700 /tmp/.pdnsd.conf
    #    chown root /tmp/.pdnsd.conf
    #    touch /Library/Caches/pdnsd/pdnsd.cache
    #    ${pkgs.pdnsd}/sbin/pdnsd -c /tmp/.pdnsd.conf
    #  '';
    #  serviceConfig.RunAtLoad = true;
    #  serviceConfig.KeepAlive = true;
    #};
  };
  launchd.user.agents = {};
  system.activationScripts.postActivation.text = ''
    chflags nohidden ${home_directory}/Library
    sudo launchctl load -w \
        /System/Library/LaunchDaemons/com.apple.atrun.plist > /dev/null 2>&1 \
        || exit 0
    cp -pL /etc/DefaultKeyBinding.dict \
       ${home_directory}/Library/KeyBindings/DefaultKeyBinding.dict
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
    etc."imapfilter.lua".source = ../files/config.lua;
    etc."configrules.lua".source = ../files/configrules.lua;
    etc."offlineimap.py".source = ../files/offlineimap.py;
    etc."msmtprc".text = ''
      defaults
      auth           on
      tls            on
      tls_trust_file ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      port           587

      account        iCloud
      host           smtp.mail.me.com
      from           jhenahan@me.com
      user           jhenahan
      passwordeval   "pass jhenahan@me.com"

      account        Outlook
      host           localhost
      port           1025
      tls            off
      from           jack.henahan@coxautoinc.com
      user           jack.henahan@coxautoinc.com
      passwordeval   "pass jack.henahan@coxautoinc.com"
    '';
    etc."ads.pdnsd".source = ../files/ads.pdnsd;
    etc."pdnsd.conf".text = ''
      global {
          perm_cache   = 65536;
          cache_dir    = "/Library/Caches/pdnsd";
          server_ip    = 127.0.0.1;
          status_ctl   = on;
          query_method = udp_tcp;
          min_ttl      = 1h;    # Retain cached entries at least 1 hour.
          max_ttl      = 4h;    # Four hours.
          timeout      = 10;    # Global timeout option (10 seconds).
          udpbufsize   = 1024;  # Upper limit on the size of UDP messages.
          neg_rrs_pol  = on;
          par_queries  = 2;
      }
    '' + home_dns.pdnsd_server + work_dns.pdnsd_server + ''
      server {
          label       = "cloudflare";
          ip          = 1.1.1.1, 1.0.0.1;
          preset      = on;
          uptest      = none;
          edns_query  = yes;
          exclude     = ".local";
          proxy_only  = on;
          purge_cache = off;
          timeout     = 5;
      }
      server {
          label       = "google";
          ip          = 8.8.8.8, 8.8.4.4;
          preset      = on;
          uptest      = none;
          edns_query  = yes;
          exclude     = ".local";
          proxy_only  = on;
          purge_cache = off;
          timeout     = 5;
      }
      server {
          label       = "comcast";
          ip          = 75.75.75.75, 75.75.76.76;
          preset      = on;
          uptest      = none;
          edns_query  = yes;
          exclude     = ".local";
          proxy_only  = on;
          purge_cache = off;
          timeout     = 5;
      }
      include {file="/etc/ads.pdnsd";}
      source {
          owner         = localhost;
          serve_aliases = on;
          file          = "/etc/hosts";
      }
      rr {
          name    = localhost;
          reverse = on;
          a       = 127.0.0.1;
          owner   = localhost;
          soa     = localhost,root.localhost,42,86400,900,86400,86400;
      }
      rr { name = localunixsocket;       a = 127.0.0.1; }
      rr { name = localunixsocket.local; a = 127.0.0.1; }
    '';
    etc."DefaultKeyBinding.dict".text = ''
      {
        "~f"    = "moveWordForward:";
        "~b"    = "moveWordBackward:";
        "~d"    = "deleteWordForward:";
        "~^h"   = "deleteWordBackward:";
        "~\010" = "deleteWordBackward:";    /* Option-backspace */
        "~\177" = "deleteWordBackward:";    /* Option-delete */
        "~v"    = "pageUp:";
        "^v"    = "pageDown:";
        "~<"    = "moveToBeginningOfDocument:";
        "~>"    = "moveToEndOfDocument:";
        "^/"    = "undo:";
        "~/"    = "complete:";
        "^g"    = "_cancelKey:";
        "^a"    = "moveToBeginningOfLine:";
        "^e"    = "moveToEndOfLine:";
        "~c"    = "capitalizeWord:"; /* M-c */
        "~u"    = "uppercaseWord:";   /* M-u */
        "~l"    = "lowercaseWord:";   /* M-l */
        "^t"    = "transpose:";      /* C-t */
        "~t"    = "transposeWords:"; /* M-t */
      }
    '';
  };
  services.nix-daemon.enable = true;
  services.activate-system.enable = true;
  services.emacs = {
    enable = false;
    package = pkgs.emacs26System;
  };

  services.offlineimap = {
    enable = true;
    path = [ pkgs.pass pkgs.mu pkgs.bash pkgs.python ];
    startInterval = 60;
    extraConfig = ''
      [general]
      pythonfile = /etc/offlineimap.py
      accounts = iCloud, Work, WorkArchive
      maxsyncaccounts = 2
    
      [Account iCloud]
      presynchook = ${pkgs.imapfilter}/bin/imapfilter -c /etc/imapfilter.lua -t ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      localrepository = LocalPersonal
      remoterepository = Personal
    
      [Account Work]
      presynchook = ${pkgs.imapfilter}/bin/imapfilter -c /etc/imapfilter.lua -t ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      localrepository = LocalWork
      remoterepository = Work

      [Account WorkArchive]
      localrepository = LocalWorkArchive
      remoterepository = WorkArchive
    
      [Repository LocalPersonal]
      type = Maildir
      sep = /
      localfolders = ~/Mail/Personal
    
      [Repository LocalWork]
      type = Maildir
      sep = /
      localfolders = ~/Mail/Work

      [Repository LocalWorkArchive]
      type = Maildir
      sep = /
      localfolders = ~/Mail/WorkArchive
    
      [Repository Personal]
      type = IMAP
      ssl = yes
      sslcacertfile = ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      remotehost = imap.mail.me.com
      remoteuser = jhenahan
      remotepasseval = get_passwordstore(item='jhenahan@me.com')
      create_folders = True
      folderfilter = lambda folder: folder in [ 'Sent Messages', 'INBOX', 'Archive', 'Deleted Messages', 'Drafts', 'haskell-cafe-archive', 'Accounts/Github' ]

      [Repository Work]
      type = IMAP
      ssl = no
      sslcacertfile = ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      remotehost = localhost
      remoteport = 1143
      remoteuser = jack.henahan@coxautoinc.com
      remotepasseval = get_passwordstore(item='jack.henahan@coxautoinc.com')
      create_folders = False
      folderfilter = lambda folder: folder in [ 'INBOX', 'Drafts', 'Sent Items', 'Deleted Items', 'Archive' ]

      [Repository WorkArchive]
      type = IMAP
      ssl = no
      sslcacertfile = ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      remotehost = localhost
      remoteport = 1143
      remoteuser = jack.henahan@coxautoinc.com
      remotepasseval = get_passwordstore(item='jack.henahan@coxautoinc.com')
      create_folders = False
      readonly = yes
      sync_deletes = no
      folderfilter = lambda folder: folder in [ 'INBOX', 'Drafts', 'Sent Items', 'Deleted Items', 'Archive' ]
    '';
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
