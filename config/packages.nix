{ pkgs }:
  with pkgs;
  let
    exe = haskell.lib.justStaticExecutables;
  in [
    nixUnstable
    nix-scripts
    nix-prefetch-scripts
    home-manager
    coreutils
    moreutils
    gist
    #git-lfs
    (gitAndTools.git-crypt)
    (gitAndTools.git-imerge)
    (gitAndTools.gitFull)
    (gitAndTools.gitflow)
    (gitAndTools.hub)
    (gitAndTools.tig)
    patch
    patchutils
    pijul
    (exe (haskPkgs.darcs))
    (pass.withExtensions (ext:
      with ext;
      [ pass-otp pass-update ]))
    bat
    browserpass
    curl
    epipe
    exa
    exiv2
    fd
    findutils
    gawk
    gnugrep
    gnupg
    gnused
    gnutar
    gpgme
    htop
    imagemagickBig
    imgcat
    jq
    less
    m-cli
    multitail
    p7zip
    paperkey
    pass-git-helper
    pinentry_mac
    qrencode
    renameutils
    ripgrep
    rlwrap
    srm
    stow
    terminal-notifier
    time
    tmux
    tree
    unrar
    unzip
    xquartz
    xsv
    xz
    zip
    (exe (haskPkgs.cabal-install))
    tokei
    cacert
    dnsutils
    httpie
    httrack
    iperf
    lftp
    mitmproxy
    mtr
    nmap
    openssh
    pdnsd
    rclone
    rsync
    sipcalc
    w3m
    wget
    youtube-dl
    ditaa
    dot2tex
    doxygen
    ffmpeg
    figlet
    fontconfig
    graphviz-nox
    groff
    highlight
    hugo
    librsvg
    (exe (haskPkgs.pandoc))
    pdf-tools-server
    plantuml
    poppler_utils
    qpdf
    (perlPackages.ImageExifTool)
    libxml2
    libxslt
    sourceHighlight
    svg2tikz
    texFull
    xdg_utils
    python27
    (python27Packages.setuptools)
    (python27Packages.pygments)
    python3
    Anki
    Dash
    Docker
    Firefox
  ]
