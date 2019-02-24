self:
  super:
{
  duma = super.callPackage ../packages/duma {};
  opmsg = super.callPackage ../packages/opmsg {};
  valgrind-light = null;
  tokei = super.tokei.overrideAttrs (attrs: {
    buildInputs = attrs.buildInputs or [] ++ super.stdenv.lib.optional super.stdenv.isDarwin super.darwin.apple_sdk.frameworks.Security;
  });
  luit = super.luit.overrideAttrs (attrs: {
    #buildInputs = attrs.buildInputs or [] ++ self.libiconv;
    #propagatedBuildInputs = attrs.propagatedBuildInputs or [] ++ self.libiconv;
    nativeBuildInputs = attrs.nativeBuildInputs or [] ++ self.libiconv;
  });
}
