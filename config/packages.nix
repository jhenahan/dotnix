{ pkgs }:
  with pkgs;
  let
    exe = haskell.lib.justStaticExecutables;
  in [
    nixStable
    nix-scripts
    nix-prefetch-scripts
    home-manager
    gnuapl
    thefuck
    #alacritty
    awscli
    awsebcli
    coreutils
    moreutils
    abduco
    #dvtm
    gist
    opmsg
    nodejs
    nodePackages.npm
    nodePackages.node2nix
    nodePackages.tern
    powershell
    mu
    #(exe (haskPkgs.cachix))
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
    ansible
    bat
    browserpass
    curl
    duma
    skim
    epipe
    emacs26System
    exa
    exiv2
    fd
    findutils
    gawk
    ghc84System
    scala
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
    rustSystem
    rustracer
    srm
    stow
    terminal-notifier
    time
    tmux
    tree
    unrar
    unzip
    #xquartz
    xsv
    xz
    zip
    #(exe (haskPkgs.cabal-install))
    #tokei
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
    terraform
    w3m
    wget
    youtube-dl
    ditaa
    dot2tex
    doxygen
    ffmpeg
    figlet
    fontconfig
    graphviz
    groff
    highlight
    hugo
    librsvg
    #(exe (haskPkgs.pandoc))
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
    python3
    python3Packages.setuptools
    python3Packages.pygments
    python-language-server
    solargraph
    Anki
    Dash
    Docker
    Firefox
    valgrind
    #LaunchBar # TODO: Figure out how to get past EULA
  ]
