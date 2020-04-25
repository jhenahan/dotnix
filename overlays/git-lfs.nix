self:
super:
{
  git-lfs = with super;
    stdenv.mkDerivation rec {
      name = "git-lfs-${version}";
      version = "2.5.2";
      src = fetchurl {
        url = "https://github.com/git-lfs/git-lfs/releases/download/v${version}/git-lfs-darwin-amd64-v${version}.tar.gz";
        sha256 = "0x7x2p35hlqcn8gxi4q255ncihg10p2xv5hlbym0cc8xkz3q1nzf";
      };
      phases = [
        "unpackPhase"
        "installPhase"
      ];
      unpackPhase = ''
        tar xvzf ${src}
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp -p git-lfs $out/bin
      '';
      meta = with stdenv.lib;
        {
          description = "An open source Git extension for versioning large files";
          homepage = "https://git-lfs.github.com/";
          license = licenses.mit;
          platforms = platforms.unix;
        };
    };
}
