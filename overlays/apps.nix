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
        version = "2.1.4";
        sourceRoot = "Anki.app";
        src = super.fetchurl {
          url = "https://apps.ankiweb.net/downloads/current/anki-${version}-mac.dmg";
          sha256 = "0vzq1kzc3z0wi2ii7b0490mllbqg2cwq32mbwh6fw853r6n4531j";
        };
        description = "Anki is a program which makes remembering things easy";
        homepage = "https://apps.ankiweb.net";
      };
      Dash = self.installApplication rec {
        name = "Dash";
        version = "4.5.2";
        sourceRoot = "Dash.app";
        src = super.fetchurl {
          url = "https://kapeli.com/downloads/v4/Dash.zip";
          sha256 = "0z8365shmwn26c2fcwv18drmi1i06myj1wspc563kaic7g7z9l4v";
        };
        description = "Dash is an API Documentation Browser and Code Snippet Manager";
        homepage = "https://kapeli.com/dash";
      };
      Docker = self.installApplication rec {
        name = "Docker";
        version = "18.06.1-ce-mac73";
        sourceRoot = "Docker.app";
        src = super.fetchurl {
          url = "https://download.docker.com/mac/stable/Docker.dmg";
          sha256 = "19a7n36nkw20rrklr8qlp76l5xhn037avqfnk81rilghik1yla9l";
        };
        description = ''
          Docker CE for Mac is an easy-to-install desktop app for building,
          debugging, and testing Dockerized apps on a Mac
        '';
        homepage = "https://store.docker.com/editions/community/docker-ce-desktop-mac";
      };
      Firefox = self.installApplication rec {
        name = "Firefox";
        version = "62.0.2";
        sourceRoot = "Firefox.app";
        src = super.fetchurl {
          name = "Firefox-${version}.dmg";
          url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
          sha256 = "185nbvnarddq594x1nwac70bg4r116ybw57xvwbmpaidvv54kgyf";
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
          export PASSWORD_STORE_DIR="$HOME/Documents/.passwords";
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
    }
