
self:
  super:
    rec {
      python = super.python.override {
        packageOverrides = python-self: python-super: {
          pytest = python-super.pytest.overridePythonAttrs (old: { checkPhase = false; });
          pytest_xdist = python-super.pytest_xdist.overridePythonAttrs (old: { checkPhase = false; });
        };
      };
      pythonPackages = python.pkgs;
      python2 = super.python2.override {
        packageOverrides = python-self: python-super: {
          pytest = python-super.pytest.overridePythonAttrs (old: { checkPhase = false; });
          pytest_xdist = python-super.pytest_xdist.overridePythonAttrs (old: { checkPhase = false; });
        };
      };
      python2Packages = python2.pkgs;
      python-language-server = 
      (super.python3Packages.python-language-server.override {
        autopep8 = super.python3Packages.autopep8;
        mccabe = super.python3Packages.mccabe;
        pycodestyle = super.python3Packages.pycodestyle;
        pydocstyle = super.python3Packages.pydocstyle;
        pyflakes = super.python3Packages.pyflakes;
        pylint = super.python3Packages.pylint;
        yapf = super.python3Packages.yapf;
      }).overridePythonAttrs (old: rec {
        version = "0.26.1";
        src = super.fetchFromGitHub {
          owner = "palantir";
          repo = "python-language-server";
          rev = version;
          sha256 = "10la48m10j4alfnpw0xw359fb833scf5kv7kjvh7djf6ij7cfsvq";
        };
      });
    }
