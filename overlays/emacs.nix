self:
pkgs:
let
  sources = import ../nix/sources.nix;
  myEmacsPackageOverrides = self:
  super:
    let
      inherit (pkgs) fetchurl
        fetchgit fetchFromGitHub stdenv
        ;
      inherit (stdenv) lib
        mkDerivation
        ;
      withPatches = pkg:
      patches:
        lib.overrideDerivation pkg (
          attrs:
            { inherit patches; }
        );
      compileEmacsFiles = pkgs.callPackage ./emacs/builder.nix;
      addBuildInputs = pkg:
      inputs:
        pkg.overrideAttrs (
          attrs:
            {
              buildInputs = attrs.buildInputs ++ inputs;
            }
        );
      addPropagatedBuildInputs = pkg:
      inputs:
        pkg.overrideAttrs (
          attrs:
            {
              propagatedBuildInputs = attrs.propagatedBuildInputs ++ inputs;
            }
        );
      notBroken = pkg:
        pkg.overrideAttrs (
          attrs:
            rec { meta.broken = false; }
        );
      compileLocalFile = name:
        compileEmacsFiles {
          inherit name;
          src = ./emacs + ("/" + name);
        };
      fetchFromEmacsWiki = pkgs.callPackage (
        { fetchurl
        , name
        , sha256
        }:
          fetchurl {
            inherit sha256;
            url = "https://www.emacswiki.org/emacs/download/" + name;
          }
      );
      compileNivFile =
        { name
        , buildInputs ? []
        , propagatedBuildInputs ? []
        , patches ? []
        }:
          compileEmacsFiles {
            inherit name buildInputs
              propagatedBuildInputs patches
              ;
            src = sources.${name};
          };
      nivOverride = p: super.${p}.overrideAttrs (
        attrs: {
          src = sources.${p};
        }
      );
      compileEmacsWikiFile =
        { name
        , sha256
        , buildInputs ? []
        , patches ? []
        }:
          compileEmacsFiles {
            inherit name buildInputs
              patches
              ;
            src = fetchFromEmacsWiki {
              inherit name sha256;
            };
          };
    in
      {
        org-reveal = compileNivFile { name = "org-reveal"; };
        flycheck = nivOverride "flycheck";
        doom-themes = nivOverride "doom-themes";
        haskell-mode = nivOverride "haskell-mode";
        company = nivOverride "company";
        evil = nivOverride "evil";
        lsp-haskell = nivOverride "lsp-haskell";
        lsp-mode = nivOverride "lsp-mode";
        lsp-ui = nivOverride "lsp-ui";
        general = nivOverride "general";
        lsp-latex = compileNivFile {
          name = "lsp-latex";
          buildInputs = [ self.lsp-mode super.s super.f super.dash super.dash-functional super.ht super.lv super.markdown-mode super.spinner ];
        };
        neuron-mode = compileNivFile {
          name = "neuron-mode";
          buildInputs = [ super.f super.s super.markdown-mode super.company ];
        };
        ctrlf = compileNivFile {
          name = "ctrlf";
        };
        prescient = compileNivFile {
          name = "prescient";
        };
        selectrum = compileNivFile {
          name = "selectrum";
        };
        blackout = compileNivFile {
          name = "blackout";
        };
        formatter = compileNivFile {
          name = "formatter";
        };
        magit = addPropagatedBuildInputs (super.magit) [ pkgs.git ];
        pdf-tools = lib.overrideDerivation super.pdf-tools (
          attrs: {
            src = fetchFromGitHub {
              owner = "politza";
              repo = "pdf-tools";
              rev = "db7de3901ae0e55f6ab8cf9baec257f706c3d16e";
              sha256 = "1vvhgxxg5lpmh0kqjgy8x1scdaah3wb76h2zj7x99ayym2bxyigv";
            };
          }
        );
        org = self.org-plus-contrib;
        org-plus-contrib = self.elpaBuild rec {
          pname = "org-plus-contrib";
          version = "master";
          src = sources.org-mode;
          meta = {
            homepage = "https://elpa.gnu.org/packages/org.html";
            license = lib.licenses.free;
          };
        };
      };
  mkEmacsPackages = emacs:
    (self.emacsPackagesNgGen emacs).overrideScope' (
      self:
      super:
        pkgs.lib.fix (
          pkgs.lib.extends myEmacsPackageOverrides (
            _:
              super.melpaPackages // {
                inherit emacs;
                inherit (super) melpaBuild
                  elpaBuild
                  ;
                inherit (super.elpaPackages) spinner;
              }
          )
        )
    );
in
{
  #emacs = pkgs.emacs26;
  emacsHEAD = with pkgs; stdenv.lib.overrideDerivation (self.emacs26.override { srcRepo = true; }) (
    attrs: rec {
      name = "emacs-${version}${versionModifier}";
      version = "27.0";
      versionModifier = ".91";

      doCheck = false;
      buildInputs = attrs.buildInputs ++ [ harfbuzz.dev jansson freetype ];

      patches = lib.optionals stdenv.isDarwin
        [
          ./emacs/patches/tramp-detect-wrapped-gvfsd.patch
          ./emacs/patches/at-fdcwd.patch
          ./emacs/patches/fix-window-role.patch
        ];

      src = ~/src/emacs;
    }
  );

  emacsHEADPackagesNg = mkEmacsPackages self.emacsHEAD;
  emacsPackagesNg = self.emacs26PackagesNg;
  emacs26PackagesNg = mkEmacsPackages (self.emacs);
  emacs26System = self.emacs26PackagesNg.emacsWithPackages;
  emacs27System = self.emacsHEADPackagesNg.emacsWithPackages;
  emacs26Env = myPkgs: pkgs.myEnvFun {
    name = "emacs26";
    buildInputs = [ (self.emacs26PackagesNg.emacsWithPackages myPkgs) ];
  };

  emacs = self.emacsHEAD;
}
