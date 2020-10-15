let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs { overlays = [ (import sources.emacs-overlay) ]; };
  gccEmacs = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacsGcc;
  };
in
gccEmacs
