{ stdenv, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  name = "skim-${version}";
  version = "v0.5.1";

  src = fetchFromGitHub {
    owner = "lotabout";
    repo = "skim";
    rev = version;
    sha256 = "1k7l93kvf5ad07yn69vjfv6znwb9v38d53xa1ij195x4img9f34j";
  };

  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  cargoSha256 = "18lgjh1b1wfm9xsd6y6slfj1i3dwrvzkzszdzk3lmqx1f8515gx7";

  meta = with stdenv.lib; {
    description = "fuzzy finder in rust";
    homepage = https://github.com/lotabout/skim;
    license = with licenses; [ mit ];
    platforms = platforms.all;
  };
}
