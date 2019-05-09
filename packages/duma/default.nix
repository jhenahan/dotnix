{ stdenv, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  name = "duma-${version}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mattgathu";
    repo = "duma";
    rev = "41dc7a443bccb94b0d9ca090609428922c03b8ca";
    sha256 = "1swnafbr2hvk1pwlg34gcpbbnc17a42ldx1wx6wsly1xgiwcx9z5";
  };

  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  doCheck = false;
  cargoSha256 = "1axmnaqjv61dgdm9qrkjpch1cj4bkd4j098if6fkwphr8gpfl29m";

  meta = with stdenv.lib; {
    description = "wget in rust";
    homepage = https://github.com/mattgathu/duma;
    license = with licenses; [ mit ];
    platforms = platforms.all;
  };
}
