self:
  super:
{
  haskell-ide-engine = (import (super.fetchFromGitHub {
    owner = "jhenahan";
    repo = "hie-nix";
    rev = "4e5ccd6c1ceaeae7f7b3963ff2c29071b8e176e7";
    sha256 = "0xnvr2d082p0vlzid9kp5plrddf8lv4zndgdhdm2a5jhq0f33fxw";
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
