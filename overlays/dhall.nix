self:
  super:
    {
      easy-dhall =
        let pkgs = super; in
        import (pkgs.fetchFromGitHub {
            owner = "jhenahan";
            repo = "easy-dhall-nix";
            rev = "21e4726e7afef16599818f6a0d4f37fde6c765b4";
            sha256 = "1103sczf2xkwgbmmkmaqf59db6q0gb18vv4v3i7py1f8nlpyv02i";
        }) {};
    }
