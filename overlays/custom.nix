self:
  super:
{
  haskell-ide-engine = (import (super.fetchFromGitHub {
    owner = "jhenahan";
    repo = "hie-nix";
    rev = "f4652dc824b896217f6415b55d2692316469a678";
    sha256 = "0kflindic0w1ndaph3lrwfgyb0a9fbhpxdvyv6264j28ki86d1c7";
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
