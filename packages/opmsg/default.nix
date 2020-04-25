{ stdenv, fetchFromGitHub, openssl }:

stdenv.mkDerivation rec {

  name = "opmsg";
  src = fetchFromGitHub {
    owner = "stealth";
    repo = "opmsg";
    rev = "888117d6ecd6594b4a58f6e2ca8541cb846b9703";
    sha256 = "1rmc9k59zmp6y1dij95ihwcj56assnhnasydjknj5ha07l69jdsi";
  };

  buildInputs = [ openssl ];

  postUnpack = "sourceRoot=\${sourceRoot}/src";

  installPhase = ''
    make all
    make contrib
    mkdir -p $out/bin
    cp opmsg $out/bin/
    cp opmux $out/bin/
    cp opcoin $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "opmsg";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
