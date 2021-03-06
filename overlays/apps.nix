self:
  super:
    {
      installApplication = { name
                           , appname ? name
                           , version
                           , src
                           , description
                           , homepage
                           , postInstall ? ""
                           , sourceRoot ? "."
                           , ... }:
        with super;
        stdenv.mkDerivation {
          name = "${name}-${version}";
          version = "${version}";
          src = src;
          buildInputs = [ undmg unzip ];
          sourceRoot = sourceRoot;
          phases = [
            "unpackPhase"
            "installPhase"
          ];
          installPhase = ''
            mkdir -p "$out/Applications/${appname}.app"
            cp -pR * "$out/Applications/${appname}.app"
          '' + postInstall;
          meta = with stdenv.lib;
          {
            description = description;
            homepage = homepage;
            platforms = platforms.darwin;
          };
        };
      Anki = self.installApplication rec {
        name = "Anki";
        version = "2.1.15";
        sourceRoot = "Anki.app";
        src = super.fetchurl {
          url = "https://apps.ankiweb.net/downloads/current/anki-${version}-mac.dmg";
          sha256 = "0l4sw46jfwz1l42d6bsrb78pi350na0prpvbizzy3bl4169khjhf";
        };
        description = "Anki is a program which makes remembering things easy";
        homepage = "https://apps.ankiweb.net";
      };
      Dash = self.installApplication rec {
        name = "Dash";
        version = "4.x";
        sourceRoot = "Dash.app";
        src = super.fetchurl {
          url = "https://kapeli.com/downloads/v4/Dash.zip";
          sha256 = "1dizd4mmmr3vrqa5x4pdbyy0g00d3d5y45dfrh95zcj5cscypdg2";
        };
        description = "Dash is an API Documentation Browser and Code Snippet Manager";
        homepage = "https://kapeli.com/dash";
      };
      Docker = self.installApplication rec {
        name = "Docker";
        version = "2.x";
        sourceRoot = "Docker.app";
        src = super.fetchurl {
          url = "https://download.docker.com/mac/stable/Docker.dmg";
          sha256 = "1nhvxi4j6sqmln5yv1d97p2ljnii2ip0k49pmhikabb75bkrhw4g";
        };
        description = ''
          Docker CE for Mac is an easy-to-install desktop app for building,
          debugging, and testing Dockerized apps on a Mac
        '';
        homepage = "https://store.docker.com/editions/community/docker-ce-desktop-mac";
      };
      Firefox = self.installApplication rec {
        name = "Firefox";
        version = "71.0";
        sourceRoot = "Firefox.app";
        src = super.fetchurl {
          name = "Firefox-${version}.dmg";
          url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
          sha256 = "1227vh040a24g335df5zz23s2wql9n57hi5kp8snk1y3rdnx5v2b";
        };
        postInstall = ''
              for file in  \
                  $out/Applications/Firefox.app/Contents/MacOS/firefox \
                  $out/Applications/Firefox.app/Contents/MacOS/firefox-bin
              do
                  dir=$(dirname "$file")
                  base=$(basename "$file")
                  mv $file $dir/.$base
                  cat > $file <<'EOF'
          #!/bin/bash
          export PATH=${super.gnupg}/bin:${super.pass}/bin:$PATH
          export PASSWORD_STORE_ENABLE_EXTENSIONS="true"
          export PASSWORD_STORE_EXTENSIONS_DIR="/run/current-system/sw/lib/password-store/extensions";
          export PASSWORD_STORE_DIR="$HOME/Dropbox/.passwords";
          export GNUPGHOME="$HOME/.config/gnupg"
          export GPG_TTY=$(tty)
          if ! pgrep -x "gpg-agent" > /dev/null; then
          ${super.gnupg}/gpgconf --launch gpg-agent
          fi
          dir=$(dirname "$0")
          name=$(basename "$0")
          exec "$dir"/."$name" "$@"
          EOF
                  chmod +x $file
              done
        '';
        description = "Mozilla Firefox (or simply Firefox) is a free and open-source web browser.";
        homepage = "https://www.mozilla.org/en-US/firefox/";
      };
      LaunchBar = self.installApplication rec {
        name = "LaunchBar";
        version = "6.9.6";
        sourceRoot = "LaunchBar.app";
        src = super.fetchurl {
          url = "https://www.obdev.at/downloads/launchbar/LaunchBar-${version}.dmg";
          sha256 = "14xr57q6iwdsp6ssvs8gmsp94kl3hnmp2yspah97qw580q9dr167";
        };
        description = ''
          Quick launcher
        '';
        homepage = "https://www.obdev.at/products/launchbar/index.html";
      };
    }
