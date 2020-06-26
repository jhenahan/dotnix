self:
super:
let
  sources = import ../nix/sources.nix;
in
{
  terraform-lsp = super.callPackage sources.terraform-lsp {};
}
