self:
  super:
{
  haskell-ide-engine = (import (super.fetchFromGitHub {
    owner = "domenkozar";
    repo = "hie-nix";
    rev = "6794005f909600679d0b7894d0e7140985920775";
    sha256 = "0pc90ns0xcsa6b630d8kkq5zg8yzszbgd7qmnylkqpa0l58zvnpn";
  }) {}).hies;
  duma = super.callPackage ../packages/duma {};
  opmsg = super.callPackage ../packages/opmsg {};
  #valgrind-light = null;
  xapian = super.xapian.overrideAttrs (attrs: {
    doCheck = false;
  });
  tokei = super.tokei.overrideAttrs (attrs: {
    buildInputs = attrs.buildInputs or [] ++ super.stdenv.lib.optional super.stdenv.isDarwin super.darwin.apple_sdk.frameworks.Security;
  });
  luit = super.luit.overrideAttrs (attrs: {
    #buildInputs = attrs.buildInputs or [] ++ self.libiconv;
    #propagatedBuildInputs = attrs.propagatedBuildInputs or [] ++ self.libiconv;
    nativeBuildInputs = attrs.nativeBuildInputs or [] ++ self.libiconv;
  });
}
