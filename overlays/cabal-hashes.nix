self:
super:
{
  all-cabal-hashes = super.fetchurl {
    url = "https://github.com/commercialhaskell/all-cabal-hashes/archive/current-hackage.tar.gz";
    sha256 = null;
  };
}
