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
}
