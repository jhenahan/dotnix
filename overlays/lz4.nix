self:
  super:
    {
      lz4 = super.lz4.overrideDerivation (attrs:
        {
          src = super.fetchFromGitHub {
            sha256 = "09c8g708gcnah5nd0m64dym17m10vg101yv2867lyp2mna7rsvh7";
            rev = "02914300185515097cdbebcd95c379508b5d3053";
            repo = "lz4";
            owner = "lz4";
          };
        });
    }
