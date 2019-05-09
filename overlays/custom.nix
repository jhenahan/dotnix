self:
  super:
{
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
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
