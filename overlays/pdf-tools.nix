self:
super:
{
  pdf-tools-server = with self;
    super.stdenv.mkDerivation rec {
      pname = "emacs-pdf-tools-server";
      version = "0.80";
      name = "${pname}-${version}";
      src = super.fetchFromGitHub {
        owner = "politza";
        repo = "pdf-tools";
        rev = "db7de3901ae0e55f6ab8cf9baec257f706c3d16e";
        sha256 = "1vvhgxxg5lpmh0kqjgy8x1scdaah3wb76h2zj7x99ayym2bxyigv";
      };
      buildInputs = [
        clang
        gnumake
        automake
        autoconf
        pkgconfig
        libpng
        zlib
        poppler
      ];
      #patches = [
      #  ./emacs/patches/pdf-tools.patch
      #];
      preConfigure = ''
        cd server
        ./autogen.sh
      '';
      installPhase = ''
        echo hello
        mkdir -p $out/bin
        cp -p epdfinfo $out/bin
      '';
      meta = with stdenv.lib;
        {
          homepage = "https://github.com/politza/pdf-tools";
          description = "Emacs support library for PDF files";
          maintainers = with maintainers;
            [ jwiegley ];
          license = licenses.gpl3;
          platforms = platforms.unix;
        };
    };
}
