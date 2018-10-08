
self:
  super:
      let 
        customConfig = builtins.readFile ../files/dvtm.h;
      in
    {
      dvtm-master = super.dvtm.overrideAttrs (attrs: {
        name = "dvtm-master";
        src = super.fetchFromGitHub {
            owner = "martanne";
            repo = "dvtm";
            rev = "311a8c0c28296f8f87fb63349e0f3254c7481e14";
            sha256 = "0pyxjkaxh8n97kccnmd3p98vi9h8mcfy5lswzqiplsxmxxmlbpx2";
          };
        patches = attrs.patches ++ [ ./dvtm/wch.patch ];
      });
      dvtm = self.dvtm-master.override { inherit customConfig; };
      }
