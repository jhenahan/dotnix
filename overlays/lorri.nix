self:
super:
let
  sources = import ../nix/sources.nix;
in
{
  lorri = super.callPackage sources.lorri {};
}
