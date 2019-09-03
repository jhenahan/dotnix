self:
  super:
    {
      easy-ps =
        let pkgs = super; in
        import (pkgs.fetchFromGitHub {
            owner = "jhenahan";
            repo = "easy-purescript-nix";
            rev = "7ad69d0206cb688f401ed3a05f66428d225b138a";
            sha256 = "1f94zp1lss5bx534hfsz56am5lmyg41hi21y28bg00sbxb4kci3x";
        }) {};
    }
