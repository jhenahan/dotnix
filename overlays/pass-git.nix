self:
  super:
    {
      pass-git-helper = with super;
      with python3Packages;
      buildPythonPackage rec {
        pname = "pass-git-helper";
        version = "0.5-dev";
        name = "${pname}-${version}";
        src = fetchFromGitHub {
          owner = "languitar";
          repo = "pass-git-helper";
          rev = "0d7712f4bb1ade0dfec1816aff40334929771c08";
          sha256 = "1nw8ziy6f5ahj41ibcnp6z4aq23f43p3bij2fp5zk3gggcd5mzvh";
        };
        buildInputs = [ pyxdg ];
        pythonPath = [ pyxdg ];
        meta = {
          homepage = "https://github.com/languitar/pass-git-helper";
          description = "A git credential helper interfacing with pass, the standard unix password manager";
          license = lib.licenses.lgpl3;
        };
      };
    }