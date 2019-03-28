self:
  super:
{
  muHEAD = super.callPackage ../nixpkgs/pkgs/tools/networking/mu {
    texinfo = super.texinfo4;
    gmime = super.gmime3.overrideDerivation (drv: { doCheck = false; });
  };
  mu = self.muHEAD.overrideDerivation (drv: {
    version = "9cf120b";
    src = super.fetchFromGitHub {
      owner  = "djcb";
      repo   = "mu";
      rev    = "9cf120b012cbe7ee4ef52299c1c0d66d08d32800";
      sha256 = "1jz0sqfq2vz27yq3jjx3fmv9ygxis67pcac435a6a51cxi98i6ba";
    };
  });
}
