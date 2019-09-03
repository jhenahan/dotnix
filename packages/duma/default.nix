{ stdenv, fetchFromGitHub, rustPlatform, darwin }:

rustPlatform.buildRustPackage rec {
  name = "duma-${version}";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "mattgathu";
    repo = "duma";
    rev = "94d796affa0425b12aaf12b81cd7d68cc3059e25";
    sha256 = "03frn4w3sk0z3kgavzjhqq85r42d956z0m4wamygzfkcj4239wgw";
  };

  buildInputs = stdenv.lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  doCheck = false;
  cargoSha256 = "06ambcdq57h0lgafb0r2v83zhmj0lg5460g8h9wjr2zxrwv8hiyd";

  meta = with stdenv.lib; {
    description = "wget in rust";
    homepage = https://github.com/mattgathu/duma;
    license = with licenses; [ mit ];
    platforms = platforms.all;
  };
}
