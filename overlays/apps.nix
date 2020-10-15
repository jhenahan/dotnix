self:
super:
{
  installApplication =
    { name
    , appname ? name
    , version
    , src
    , description
    , homepage
    , postInstall ? ""
    , sourceRoot ? "."
    , ...
    }:
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
      sha256 = "0819p460jpymbfrb2c72zr61aiw191wivrq3ii3sfq3zck233d2d";
    };
    description = ''
      Docker CE for Mac is an easy-to-install desktop app for building,
      debugging, and testing Dockerized apps on a Mac
    '';
    homepage = "https://store.docker.com/editions/community/docker-ce-desktop-mac";
  };
  Firefox = self.installApplication rec {
    name = "Firefox";
    version = "80.0.1";
    sourceRoot = "Firefox.app";
    src = super.fetchurl {
      name = "Firefox-${version}.dmg";
      url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
      sha256 = "1l3gkkmxbgzjn72ncvbpk2br2j08sgvzrmlgcvv0hdn9rwnbnb18";
    };
    description = "Mozilla Firefox (or simply Firefox) is a free and open-source web browser.";
    homepage = "https://www.mozilla.org/en-US/firefox/";
  };
  LaunchBar = self.installApplication rec {
    name = "LaunchBar";
    version = "6.12";
    sourceRoot = "LaunchBar.app";
    src = super.fetchurl {
      url = "https://www.obdev.at/downloads/launchbar/LaunchBar-${version}.dmg";
      sha256 = "16a18s2by9yrybzqpcblr5dr6mpj8fdw0wya4x5zvc1ya9w9qc04";
    };
    description = ''
      Quick launcher
    '';
    homepage = "https://www.obdev.at/products/launchbar/index.html";
  };
}
