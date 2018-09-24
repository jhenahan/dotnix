{ pkgs, ... }:
  let
    home_directory = builtins.getEnv "HOME";
    ca-bundle_crt = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    lib = pkgs.stdenv.lib;
  in rec {
    manual.manpages.enable = false;
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowBroken = true;
      };
      overlays = let
        path = ../overlays;
      in with builtins;
      map (n:
        import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (attrNames (readDir path)));
    };
#    services = {
#      gpg-agent = {
#        enable = true;
#        defaultCacheTtl = 1800;
#        enableSshSupport = true;
#      };
#    };
    home = {
      packages = with pkgs;
      [];
      sessionVariables = {
        CABAL_CONFIG = "${xdg.configHome}/cabal/config";
        GNUPGHOME = "${xdg.configHome}/gnupg";
        LESSHISTFILE = "${xdg.cacheHome}/less/history";
        SCREENRC = "${xdg.configHome}/screen/config";
        SSH_AUTH_SOCK = "${xdg.configHome}/gnupg/S.gpg-agent.ssh";
        WWW_HOME = "${xdg.cacheHome}/w3m";
        FONTCONFIG_PATH = "${xdg.configHome}/fontconfig";
        FONTCONFIG_FILE = "${xdg.configHome}/fontconfig/fonts.conf";
        PASSWORD_STORE_DIR = "${home_directory}/Documents/.passwords";
        NIX_CONF = "${home_directory}/src/dotnix";
        EMACSVER = "26";
        GHCVER = "84";
        GHCPKGVER = "843";
        ALTERNATE_EDITOR = "";
        EMACS_SERVER_FILE = "/tmp/emacsclient.server";
        COLUMNS = "100";
        EDITOR = "${pkgs.emacs26}/bin/emacsclient -s /tmp/emacs501/server -c";
        EMAIL = "${programs.git.userEmail}";
        GRAPHVIZ_DOT = "${pkgs.graphviz}/bin/dot";
        JAVA_OPTS = "-Xverify:none";
        LC_CTYPE = "en_US.UTF-8";
        LESS = "-FRSXM";
        PROMPT_DIRTRIM = "2";
        TINC_USE_NIX = "yes";
        WORDCHARS = "";
      };
      file = builtins.listToAttrs (map (path:
        {
          name = path;
          value = {
            source = builtins.toPath "${home_directory}/src/home/${path}";
          };
        }) [
        "Library/Scripts/Applications/Download links to PDF.scpt"
        "Library/Scripts/Applications/Media Pro"
      ]) // {
        ".docker".source = "${xdg.configHome}/docker";
        ".gist".source = "${xdg.configHome}/gist/account_id";
        ".curlrc".text = ''
          capath=${pkgs.cacert}/etc/ssl/certs/
          cacert=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
        '';
      };
    };
    programs = {
      home-manager = {
        enable = true;
        path = "${home_directory}/src/dotnix/home-manager";
      };
      browserpass = {
        enable = true;
        browsers = [ "firefox" ];
      };
      direnv = { enable = true; };
      fish = {
        enable = true;
        shellAliases = {
          e = "\$EDITOR -n";
          E = "sudo -e";
          ls = "exa";
          l = "exa";
          ll = "exa -al";
        };
        loginShellInit = ''
          set -x GPG_TTY (tty)
          if not pgrep -x "gpg-agent" > /dev/null
              ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
          end
        '';
        shellInit = ''
          set -x SSH_AUTH_SOCK (${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket)
        '';
      };
      git = {
        enable = true;
        userName = "Jack Henahan";
        userEmail = "jack.henahan@uvmhealth.org";
        signing = {
          key = "17F07DF3086C4BBF";
          signByDefault = false;
        };
        aliases = {
          amend = "commit --amend -C HEAD";
          authors = "!\"${pkgs.git}/bin/git log --pretty=format:%aN" + " | ${pkgs.coreutils}/bin/sort" + " | ${pkgs.coreutils}/bin/uniq -c" + " | ${pkgs.coreutils}/bin/sort -rn\"";
          b = "branch --color -v";
          ca = "commit --amend";
          changes = "diff --name-status -r";
          clone = "clone --recursive";
          co = "checkout";
          cp = "cherry-pick";
          dc = "diff --cached";
          dh = "diff HEAD";
          ds = "diff --staged";
          from = "!${pkgs.git}/bin/git bisect start && ${pkgs.git}/bin/git bisect bad HEAD && ${pkgs.git}/bin/git bisect good";
          ls-ignored = "ls-files --exclude-standard --ignored --others";
          nb = "!${pkgs.git}/bin/git checkout --track \$(${pkgs.git}/bin/git config branch.\$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD).remote)/\$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD) -b";
          rc = "rebase --continue";
          rh = "reset --hard";
          ri = "rebase --interactive";
          rs = "rebase --skip";
          ru = "remote update --prune";
          snap = "!${pkgs.git}/bin/git stash" + " && ${pkgs.git}/bin/git stash apply";
          snaplog = "!${pkgs.git}/bin/git log refs/snapshots/refs/heads/" + "\$(${pkgs.git}/bin/git rev-parse HEAD)";
          spull = "!${pkgs.git}/bin/git stash" + " && ${pkgs.git}/bin/git pull" + " && ${pkgs.git}/bin/git stash pop";
          su = "submodule update --init --recursive";
          undo = "reset --soft HEAD^";
          w = "status -sb";
          wdiff = "diff --color-words";
          l = "log --graph --pretty=format:'%Cred%h%Creset" + " —%Cblue%d%Creset %s %Cgreen(%cr)%Creset'" + " --abbrev-commit --date=relative --show-notes=*";
        };
        extraConfig = {
          core = {
            editor = "${pkgs.emacs26}/bin/emacsclient -s /tmp/emacs501/server -c";
            trustctime = false;
            fsyncobjectfiles = true;
            pager = "${pkgs.less}/bin/less --tabs=4 -RFX";
            logAllRefUpdates = true;
            precomposeunicode = false;
            whitespace = "trailing-space,space-before-tab";
          };
          branch.autosetupmerge = true;
          commit.gpgsign = true;
          github.user = "jhenahan";
          credential.helper = "${pkgs.pass-git-helper}/bin/pass-git-helper";
          ghi.token = "!${pkgs.pass}/bin/pass api.github.com | head -1";
          hub.protocol = "${pkgs.openssh}/bin/ssh";
          mergetool.keepBackup = true;
          pull.rebase = true;
          rebase.autosquash = true;
          rerere.enabled = true;
          "merge \"ours\"".driver = true;
          "magithub \"ci\"".enabled = false;
          http = {
            sslCAinfo = "${ca-bundle_crt}";
            sslverify = true;
          };
          color = {
            status = "auto";
            diff = "auto";
            branch = "auto";
            interactive = "auto";
            ui = "auto";
            sh = "auto";
          };
          push = {
            default = "tracking";
            recurseSubmodules = "check";
          };
          merge = {
            conflictstyle = "diff3";
            stat = true;
          };
          "color \"sh\"" = {
            branch = "yellow reverse";
            workdir = "blue bold";
            dirty = "red";
            dirty-stash = "red";
            repo-state = "red";
          };
          annex = {
            backends = "SHA512E";
            alwayscommit = false;
          };
          "filter \"media\"" = {
            required = true;
            clean = "${pkgs.git}/bin/git media clean %f";
            smudge = "${pkgs.git}/bin/git media smudge %f";
          };
          submodule = { recurse = true; };
          diff = {
            ignoreSubmodules = "dirty";
            renames = "copies";
            mnemonicprefix = true;
          };
          advice = {
            statusHints = false;
            pushNonFastForward = false;
          };
          #"filter \"lfs\"" = {
          #  clean = "${pkgs.git-lfs}/bin/git-lfs clean -- %f";
          #  smudge = "${pkgs.git-lfs}/bin/git-lfs smudge --skip -- %f";
          #  required = true;
          #};
          "url \"git://github.com/ghc/packages-\"".insteadOf = "git://github.com/ghc/packages/";
          "url \"http://github.com/ghc/packages-\"".insteadOf = "http://github.com/ghc/packages/";
          "url \"https://github.com/ghc/packages-\"".insteadOf = "https://github.com/ghc/packages/";
          "url \"ssh://git@github.com/ghc/packages-\"".insteadOf = "ssh://git@github.com/ghc/packages/";
          "url \"git@github.com:/ghc/packages-\"".insteadOf = "git@github.com:/ghc/packages/";
        };
        ignores = [
          "*.elc"
          "*.vo"
          "*.aux"
          "*.v.d"
          "*.o"
          "*.a"
          "*.la"
          "*.so"
          "*.dylib"
          "*~"
          "#*#"
          ".makefile"
          ".clean"
          ".envrc"
          ".direnv"
          "*.glob"
          ".DS_Store"
        ];
      };
      ssh = {
        enable = true;
        forwardAgent = true;
        serverAliveInterval = 60;
        hashKnownHosts = true;
        userKnownHostsFile = "${xdg.configHome}/ssh/known_hosts";
        matchBlocks = {
          id_local = {
            host = "*";
            identityFile = "${xdg.configHome}/ssh/id_local";
            identitiesOnly = true;
          };
        };
      };
    };
    xdg = {
      enable = true;
      configHome = "${home_directory}/.config";
      dataHome = "${home_directory}/.local/share";
      cacheHome = "${home_directory}/.cache";
      configFile."gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
        default-cache-ttl 600
        max-cache-ttl 7200
        pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
        scdaemon-program ${xdg.configHome}/gnupg/scdaemon-wrapper
      '';
      configFile."gnupg/scdaemon-wrapper" = {
        text = ''
          #!/bin/bash
          export DYLD_FRAMEWORK_PATH=/System/Library/Frameworks
          exec ${pkgs.gnupg}/libexec/scdaemon "$@"
        '';
        executable = true;
      };
    };
  }
