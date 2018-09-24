{ config, lib, pkgs, ... }:
  let
    home_directory = "/Users/jackhenahan";
    logdir = "${home_directory}/Library/Logs";
  in {
    system.defaults = import ./darwin/defaults.nix;
    networking = {
      dns = [ "127.0.0.1" ];
      search = [ "local" ];
      knownNetworkServices = [
        "Ethernet"
        "Wi-Fi"
      ];
    };
    launchd.daemons = {
      pdnsd = {
        script = ''
          cp -pL /etc/pdnsd.conf /tmp/.pdnsd.conf
          chmod 700 /tmp/.pdnsd.conf
          chown root /tmp/.pdnsd.conf
          touch /Library/Caches/pdnsd/pdnsd.cache
          ${pkgs.pdnsd}/sbin/pdnsd -c /tmp/.pdnsd.conf
        '';
        serviceConfig.RunAtLoad = true;
        serviceConfig.KeepAlive = true;
      };
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
      };
      overlays = let
        path = ../overlays;
      in with builtins;
      map (n:
        import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (attrNames (readDir path))) ++ [
        (import ./envs.nix)
      ];
    };
    environment = {
      systemPackages = import ./packages.nix {
        inherit pkgs;
      };
      systemPath = [
        "${pkgs.Docker}/Applications/Docker.app/Contents/Resources/bin"
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
      etc."pdnsd.conf".text = ''
        global {
            perm_cache   = 8192;
            cache_dir    = "/Library/Caches/pdnsd";
            server_ip    = 127.0.0.1;
            status_ctl   = on;
            query_method = udp_tcp;
            min_ttl      = 1h;    # Retain cached entries at least 1 hour.
            max_ttl      = 4h;    # Four hours.
            timeout      = 10;    # Global timeout option (10 seconds).
            udpbufsize   = 1024;  # Upper limit on the size of UDP messages.
            neg_rrs_pol  = on;
            par_queries  = 1;
        }
        server {
            label       = "cloudflare";
            ip          = 1.1.1.1, 1.0.0.1;
            preset      = on;
            uptest      = none;
            edns_query  = yes;
            exclude     = ".local";
            proxy_only  = on;
            purge_cache = off;
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
        }
        server {
            label       = "dyndns";
            ip          = 216.146.35.35, 216.146.36.36;
            preset      = on;
            uptest      = none;
            edns_query  = yes;
            exclude     = ".local";
            proxy_only  = on;
            purge_cache = off;
        }
        # The servers provided by OpenDNS are fast, but they do not reply with
        # NXDOMAIN for non-existant domains, instead they supply you with an
        # address of one of their search engines. They also lie about the
        # addresses of the search engines of google, microsoft and yahoo. If you
        # do not like this behaviour the "reject" option may be useful.
        server {
            label       = "opendns";
            ip          = 208.67.222.222, 208.67.220.220;
            # You may need to add additional address ranges here if the addresses
            # of their search engines change.
            reject      = 208.69.32.0/24,
                          208.69.34.0/24,
                          208.67.219.0/24;
            preset      = on;
            uptest      = none;
            edns_query  = yes;
            exclude     = ".local";
            proxy_only  = on;
            purge_cache = off;
        }
        # This section is meant for resolving from root servers.
        server {
            label             = "root-servers";
            root_server       = discover;
            ip                = 198.41.0.4, 192.228.79.201;
            randomize_servers = on;
        }
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
        rr { name = bugs.ledger-cli.org;   a = 192.168.128.132; }
        neg {
            name  = doubleclick.net;
            types = domain;           # This will also block xxx.doubleclick.net, etc.
        }
        neg {
            name  = bad.server.com;   # Badly behaved server you don't want to connect to.
            types = A,AAAA;
        }
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
          "~c"	  = "capitalizeWord:"; /* M-c */
          "~u"	  = "uppercaseWord:";	 /* M-u */
          "~l"	  = "lowercaseWord:";	 /* M-l */
          "^t"	  = "transpose:";      /* C-t */
          "~t"	  = "transposeWords:"; /* M-t */
        }
      '';
    };
    services.nix-daemon.enable = true;
    services.activate-system.enable = true;
    nix = {
      package = pkgs.nixUnstable;
      nixPath = [
        "darwin-config=\$HOME/src/dotnix/config/darwin.nix"
        "home-manager=\$HOME/src/dotnix/home-manager"
        "darwin=\$HOME/src/dotnix/darwin"
        "nixpkgs=\$HOME/src/dotnix/nixpkgs"
      ];
      trustedUsers = [
        "root"
        "jackhenahan"
        "@admin"
        "@wheel"
      ];
      maxJobs = 8;
      buildCores = 8;
      gc.automatic = true;
      gc.options = "--max-freed \$((25 * 1024**3 - 1024 * \$(df -P -k /nix/store | tail -n 1 | awk '{ print \$4 }')))";
      distributedBuilds = false;
      binaryCaches = [
        "https://cache.nixos.org"
      ];
      binaryCachePublicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    programs.bash.enable = true;
    programs.fish = {
      enable = true;
      vendor.config.enable = true;
      vendor.completions.enable = true;
      vendor.functions.enable = true;
    };
    programs.nix-index.enable = true;
    system.stateVersion = 2;
  }
