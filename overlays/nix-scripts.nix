self: super: {

  nix-scripts = with self; stdenv.mkDerivation {
    name = "nix-scripts";

    src = ../bin;

    buildInputs = [];

    installPhase = ''
      mkdir -p $out/bin
      find . -maxdepth 1 \( -type f -o -type l \) -executable \
          -exec cp -pL {} $out/bin \;
    '';

    meta = with stdenv.lib; {
      description = "Various scripts";
      license = licenses.mit;
      platforms = platforms.darwin;
    };
  };

}
