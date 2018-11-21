{ stdenv, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  name = "duma-${version}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mattgathu";
    repo = "duma";
    rev = "6059ae31de49a768a573f42c96f7a7be794a9eca";
    sha256 = "1shp4a84q4q7fdm94s3jxvsygy9mhr77hphpw4j7bkrms81wqnpd";
  };

  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  doCheck = false;
  cargoSha256 = "1gzjch3iz2snkdgrl61jq2j0f11f2vi4w1byvpw5akrn9yyscbrg";

  meta = with stdenv.lib; {
    description = "wget in rust";
    homepage = https://github.com/mattgathu/duma;
    license = with licenses; [ mit ];
    platforms = platforms.all;
  };
}
