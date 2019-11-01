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
        version = "2.1.7";
        sourceRoot = "Anki.app";
        src = super.fetchurl {
          url = "https://apps.ankiweb.net/downloads/current/anki-${version}-mac.dmg";
          sha256 = "0zh7gymlh47lldhkxqpj4bsyzsa66chfzzygvv7kzb4wzay53l8m";
        };
        description = "Anki is a program which makes remembering things easy";
        homepage = "https://apps.ankiweb.net";
      };
      Dash = self.installApplication rec {
        name = "Dash";
        version = "4.6.5";
        sourceRoot = "Dash.app";
        src = super.fetchurl {
          url = "https://kapeli.com/downloads/v4/Dash.zip";
          sha256 = "0zvc119n30ya7xja4f2ksgqcdf8c4xjzszr8w0zgm8w65nfsi8y1";
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
          sha256 = "06nhg3hddzn3l7yky36drypjkcvbbc2qbyazkjj0i0yq09knjf5n";
        };
        description = ''
          Docker CE for Mac is an easy-to-install desktop app for building,
          debugging, and testing Dockerized apps on a Mac
        '';
        homepage = "https://store.docker.com/editions/community/docker-ce-desktop-mac";
      };
      Firefox = self.installApplication rec {
        name = "Firefox";
        version = "70.0";
        sourceRoot = "Firefox.app";
        src = super.fetchurl {
          name = "Firefox-${version}.dmg";
          url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
          sha256 = "0z0r4h2s1rb4hjrm5zcprmfip2iaa85mxznhm6lczvm46jy8zjra";
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
