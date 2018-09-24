self:
  super:
    {
      pdf-tools-server = with self;
      super.stdenv.mkDerivation rec {
        pname = "emacs-pdf-tools-server";
        version = "20180428.1527";
        name = "${pname}-${version}";
        src = super.fetchFromGitHub {
          owner = "politza";
          repo = "pdf-tools";
          rev = "8aa7aecf19090692d910036f256f67c1b8968a75";
          sha256 = "0mhby1sjnw0vvwl1yjfqmhwk9nxv1chl3qxrvkd7n51d03bfrr3j";
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
        patches = [
          ./emacs/patches/pdf-tools.patch
        ];
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