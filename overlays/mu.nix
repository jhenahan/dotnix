self:
  super:
{
  mu = (super.callPackage ../nixpkgs/pkgs/tools/networking/mu {
    texinfo = super.texinfo4;
    gmime = super.gmime3.overrideDerivation (drv: { doCheck = false; });
  }).overrideDerivation (drv: {
    version = "1.2";
    src = super.fetchFromGitHub {
      owner  = "djcb";
      repo   = "mu";
      rev    = "f62b4e534a7ef2acea3d87c54f7b4f19cec01afd";
      sha256 = "0yhjlj0z23jw3cf2wfnl98y8q6gikvmhkb8vdm87bd7jw0bdnrfz";
    };
  });
}
