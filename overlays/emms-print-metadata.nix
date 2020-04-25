self:
super:
{
  emms-print-metadata = with self;
    super.stdenv.mkDerivation rec {
      pname = "emacs-emms-print-metadata";
      version = "5.1";
      name = "${pname}-${version}";
      src = fetchgit {
        url = "git://git.sv.gnu.org/emms.git";
        rev = "4eed4ce2f8105245617e5e529077c5a6635e45f8";
        sha256 = "13sjk9as6baibmp2wbjl94648a0j55jyjizm2jzhzl37qq791pmg";
      };
      buildInputs = [
        clang
        gnumake
        automake
        autoconf
        pkgconfig
        taglib
      ];
      buildPhase = ''
        make emms-print-metadata
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp -p src/emms-print-metadata $out/bin
      '';
      meta = with stdenv.lib;
        {
          homepage = "https://www.gnu.org/software/emms/";
          description = "EMMS, The Emacs Multimedia System";
          maintainers = [];
          license = licenses.gpl3;
          platforms = platforms.unix;
        };
    };
}
