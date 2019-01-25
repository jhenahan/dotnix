self:
  super:
{
  duma = super.callPackage ../packages/duma {};
  opmsg = super.callPackage ../packages/opmsg {};
  valgrind-light = null;
  luit = super.luit.overrideAttrs (attrs: {
    #buildInputs = attrs.buildInputs or [] ++ self.libiconv;
    #propagatedBuildInputs = attrs.propagatedBuildInputs or [] ++ self.libiconv;
    nativeBuildInputs = attrs.nativeBuildInputs or [] ++ self.libiconv;
  });
}
