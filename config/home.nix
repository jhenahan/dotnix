{ pkgs, ... }:
  let
    home_directory = builtins.getEnv "HOME";
    ca-bundle_crt = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    work_ssh = import ../private/work/ssh.nix;
    gh_oauth = (import ../private/vars.nix).oauth_token;
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
        match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (attrNames (readDir path))) ++ [
        (import ./envs.nix)
      ];
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
        PASSWORD_STORE_DIR = "${home_directory}/Dropbox/.passwords";
        NIX_CONF = "${home_directory}/src/dotnix";
        OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES";
        EMACSVER = "26";
        GHCVER = "84";
        GHCPKGVER = "843";
        ALTERNATE_EDITOR = "";
        COLUMNS = "100";
        EDITOR = "${pkgs.emacs26System}/bin/emacsclient -ct";
        VISUAL = "${pkgs.emacs26System}/bin/emacsclient -cn";
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
      ]) // { ".docker".source = "${xdg.configHome}/docker";
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
          e = "eval \$VISUAL -n";
          E = "sudo -e";
          ls = "exa";
          l = "exa";
          ll = "exa -al";
          ghci = "command ghci -hide-package base -package rerebase";
          ghc = "command ghc -liconv";
        };
        loginShellInit = ''
          set fish_greeting
          set -x GPG_TTY (tty)
          if not pgrep -x "gpg-agent" > /dev/null
              ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent
          end
        '';
        promptInit = ''
          function fish_prompt
          
            function _git_branch_name
              echo (command git rev-parse --abbrev-ref HEAD ^/dev/null)
            end
          
            function _is_git_dirty
              echo (command git status -s --ignore-submodules=dirty ^/dev/null)
            end
          
            function _git_short_hash
              echo (command git rev-parse --short HEAD ^/dev/null)
            end

            function __format_time -d "Format milliseconds to a human readable format"
              set -l milliseconds $argv[1]
              set -l seconds (math "$milliseconds / 1000 % 60")
              set -l minutes (math -s0 "$milliseconds / 60000 % 60")
              set -l hours (math -s0 "$milliseconds / 3600000 % 24")
              set -l days (math -s0 "$milliseconds / 86400000")
              set -l time
              set -l threshold $argv[2]
            
              if test $days -gt 0
                set time (command printf "$time%sd " $days)
              end
            
              if test $hours -gt 0
                set time (command printf "$time%sh " $hours)
              end
            
              if test $minutes -gt 0
                set time (command printf "$time%sm " $minutes)
              end
              if test $seconds -gt $threshold
                set time (command printf "$time%ss " $seconds)
              end
            
              echo -e $time
            end

            function _command_time
              set -l yellow (set_color yellow)
              set -l normal (set_color normal)
              if test -n "$CMD_DURATION"
                set command_duration (__format_time $CMD_DURATION 5)
              end

              echo -e "$yellow$command_duration$normal"
            end
          
            switch $USER
          
            case root
              if not set -q __fish_prompt_cwd
                if set -q fish_color_cwd_root
                  set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
                else
                  set -g __fish_prompt_cwd (set_color $fish_color_cwd)
                end
              end
            
            case '*'
              if not set -q __fish_prompt_cwd
                set -g __fish_prompt_cwd (set_color $fish_color_cwd)
              end
            end
          
            set -l green (set_color green)
            set -l red (set_color red)
            set -l ugreen (set_color -u cyan)
            set -l normal (set_color normal)
          
            set -l arrow 'λ'
            set -l cwd $__fish_prompt_cwd(basename (prompt_pwd))$normal
            
          
            if [ (_git_branch_name) ]
              set git_info $green(_git_branch_name)
              set git_hash $ugreen(_git_short_hash)$normal
              set git_info ":$git_info$normal [$git_hash]"
          
              set dirty "💔"
              set clean "❤️"
                
              if [ (_is_git_dirty) ]
                set git_info "$git_info$dirty "
              else
                set git_info "$git_info$clean "
              end
            end
          
            set -l git_info $git_info$normal
            
            echo -e -n -s '╭─ 正念 ' $cwd \
          	$git_info ' ' (_command_time) \
          	'\n╰─ ' $arrow ' '
          end
        '';

        shellInit = ''
          set -x SSH_AUTH_SOCK "${xdg.configHome}/gnupg/S.gpg-agent.ssh";
          set -x GNUPGHOME "${xdg.configHome}/gnupg";

          set -x CABAL_CONFIG "${xdg.configHome}/cabal/config";
          set -x LESSHISTFILE "${xdg.cacheHome}/less/history";
          set -x SCREENRC "${xdg.configHome}/screen/config";
          set -x WWW_HOME "${xdg.cacheHome}/w3m";
          set -x OBJC_DISABLE_INITIALIZE_FORK_SAFETY "YES";
          set -x FONTCONFIG_PATH "${xdg.configHome}/fontconfig";
          set -x FONTCONFIG_FILE "${xdg.configHome}/fontconfig/fonts.conf";
          set -x PASSWORD_STORE_DIR "${home_directory}/Dropbox/.passwords";
          set -x NIX_CONF "${home_directory}/src/dotnix";
          set -x EMACSVER "26";
          set -x GHCVER "84";
          set -x GHCPKGVER "843";
          set -x ALTERNATE_EDITOR "";
          set -x COLUMNS "100";
          set -x EDITOR "${pkgs.emacs26System}/bin/emacsclient -ct";
          set -x VISUAL "${pkgs.emacs26System}/bin/emacsclient -cn";
          set -x DVTM_EDITOR vim
          set -x EMAIL "${programs.git.userEmail}";
          set -x GRAPHVIZ_DOT "${pkgs.graphviz}/bin/dot";
          set -x JAVA_OPTS "-Xverify:none";
          set -x LC_CTYPE "en_US.UTF-8";
          set -x LESS "-FRSXM";
          set -x PROMPT_DIRTRIM "2";
          set -x TINC_USE_NIX "yes";
          set -x WORDCHARS "";
          set -x SKIM_DEFAULT_COMMAND 'rg --color=always --line-number "{}"'
          set -x SKIM_DEFAULT_OPTIONS '--ansi --regex'
          set -x SHELL "${pkgs.fish}/bin/fish"
          set -x PATH /Users/JHENAHAN/.nix-profile/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin $PATH
          function dvtm_title --on-event fish_prompt
             set -l host (hostname)
             set -l dir (string replace $HOME '~' $PWD)
             echo -ne "\033]0;$USER@$host:$dir\007"
          end
          function wtr -a format
            set -q format[1]; and set -l f "&format=$format[1]"; or set -l f ""
            curl "https://wttr.in/?m$f"
          end
          function cheat -a topic
            set -q topic[1]; and curl "https://cht.sh/$topic[1]/$argv[2..-1]"
          end
        '';
      };
      git = {
        enable = true;
        userName = "Jack Henahan";
        userEmail = "root@proofte.ch";
        signing = {
          key = "17F07DF3086C4BBFA5799F38EF21DED4826AAFCF";
          signByDefault = true;
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
            editor = "${pkgs.emacs26System}/bin/emacsclient -c";
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
          github.oauth-token = gh_oauth;
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
          default = {
            host = "*";
            identityFile = "${xdg.configHome}/ssh/id_local";
            identitiesOnly = true;
          };
          #work = (work_ssh xdg).ssh;
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
