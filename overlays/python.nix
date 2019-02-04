
self:
  super:
    {
      python-language-server = super.python3Packages.python-language-server.override {
        autopep8 = super.python3Packages.autopep8;
        mccabe = super.python3Packages.mccabe;
        pycodestyle = super.python3Packages.pycodestyle;
        pydocstyle = super.python3Packages.pydocstyle;
        pyflakes = super.python3Packages.pyflakes;
        yapf = super.python3Packages.yapf;
      };
    }
