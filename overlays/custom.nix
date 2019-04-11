self:
  super:
{
  haskell-ide-engine = (import (super.fetchFromGitHub {
    owner = "domenkozar";
    repo = "hie-nix";
    rev = "922bbc7bf85b3b51df9534d5799e8310cc0387c9";
    sha256 = "1wf80g1zbgglc3lyqrzfdaqrzhdgmzhgg1p81hd2cpp57gpai9wh";
  }) {}).hie86;
  alacritty = super.callPackage ../packages/alacritty {
    inherit (super.darwin.apple_sdk.frameworks)
      AppKit CoreFoundation CoreGraphics CoreServices
      CoreText Foundation OpenGL;
    inherit (super.darwin) cf-private;
  };
  duma = super.callPackage ../packages/duma {};
  opmsg = super.callPackage ../packages/opmsg {};
  terragrunt = super.terragrunt.overrideAttrs (attrs: {
    postInstall = ''
      wrapProgram $bin/bin/terragrunt \
        --set TERRAGRUNT_TFPATH ${super.stdenv.lib.getBin super.terraform}/bin/terraform
    '';
  });
  tokei = super.tokei.overrideAttrs (attrs: {
    buildInputs = attrs.buildInputs or [] ++ super.stdenv.lib.optionals super.stdenv.isDarwin [ super.darwin.apple_sdk.frameworks.Security super.libiconv ];
  });
  xapian = super.xapian.overrideAttrs (attrs: {
    doCheck = false;
  });
  luit = super.luit.overrideAttrs (attrs: {
    #buildInputs = attrs.buildInputs or [] ++ self.libiconv;
    #propagatedBuildInputs = attrs.propagatedBuildInputs or [] ++ self.libiconv;
    nativeBuildInputs = attrs.nativeBuildInputs or [] ++ self.libiconv;
  });
}
