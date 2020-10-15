self:
super:
let
  sources = import ../nix/sources.nix;
in
{
  neuron = import sources.neuron {};
  duma = super.callPackage ../packages/duma {};
  sbt = super.callPackage ../packages/sbt {};
  opmsg = super.callPackage ../packages/opmsg {};
  emacsMacport = with super; super.emacsMacport.override {
    stdenv = if stdenv.cc.isClang then llvmPackages_6.stdenv else stdenv;
  };
  terragrunt = super.terragrunt.overrideAttrs (
    attrs: {
      postInstall = ''
        wrapProgram $bin/bin/terragrunt \
          --set TERRAGRUNT_TFPATH ${super.stdenv.lib.getBin super.terraform}/bin/terraform
      '';
    }
  );
  gpgme = super.gpgme.overrideAttrs (
    attrs: {
      doCheck = false;
    }
  );
  git = super.git.overrideAttrs (
    attrs: {
      doInstallCheck = false;
    }
  );
  libpsl = super.libpsl.overrideAttrs (
    attrs: {
      doCheck = false;
    }
  );
  tokei = super.tokei.overrideAttrs (
    attrs: {
      buildInputs = attrs.buildInputs or [] ++ super.stdenv.lib.optionals super.stdenv.isDarwin [ super.darwin.apple_sdk.frameworks.Security super.libiconv ];
    }
  );
  xapian = super.xapian.overrideAttrs (
    attrs: {
      doCheck = false;
    }
  );
  luit = super.luit.overrideAttrs (
    attrs: {
      #buildInputs = attrs.buildInputs or [] ++ self.libiconv;
      #propagatedBuildInputs = attrs.propagatedBuildInputs or [] ++ self.libiconv;
      nativeBuildInputs = attrs.nativeBuildInputs or [] ++ self.libiconv;
    }
  );
}
