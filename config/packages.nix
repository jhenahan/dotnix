{ pkgs }:
  with pkgs;
  let
    exe = haskell.lib.justStaticExecutables;
  in [
    (exe haskPkgs.pointful)
    (exe haskPkgs.pointfree)
    (exe haskPkgs.darcs)
    (exe haskPkgs.ShellCheck)
    (exe haskPkgs.alex)
    (exe haskPkgs.happy)
    (exe haskPkgs.cabal-install)
    (exe haskPkgs.c2hsc)
    (exe haskPkgs.cabal2nix)
    (exe haskPkgs.cpphs)
    (exe haskPkgs.doctest)
    (exe haskPkgs.ghc-core)
    (exe haskPkgs.hlint)
    (exe haskPkgs.hnix)
    (exe haskPkgs.structured-haskell-mode)
    (exe haskPkgs.stylish-haskell)
    nixStable
    nix-scripts
    nix-prefetch-scripts
    home-manager
    emacs-all-the-icons-fonts
    exercism
    du-dust
    procs
    #gnuapl
    kotlin
    mpv
    jre
    stoken
    thefuck
    aria
    alacritty
    hie865
    tealdeer
    emms-print-metadata
    mb2md
    packer
    imapfilter
    isync
    awscli
    awsebcli
    coreutils
    moreutils
    swagger-codegen
    abduco
    gist
    opmsg
    nodePackages.node2nix
    nodePackages.tern
    powershell
    mu
    msmtp
    mysql
    cachix
    git-lfs
    (gitAndTools.git-crypt)
    (gitAndTools.git-imerge)
    (gitAndTools.gitFull)
    (gitAndTools.bfg-repo-cleaner)
    (gitAndTools.gitflow)
    (gitAndTools.hub)
    (gitAndTools.tig)
    (gitAndTools.diff-so-fancy)
    patch
    patchutils
    pijul
    (pass.withExtensions (ext:
      with ext;
      [ pass-otp pass-update ]))
    ansible
    bat
    browserpass
    curl
    #duma
    skim
    epipe
    emacs26System
    exa
    exiv2
    fd
    findutils
    gawk
    ghc86System
    scala
    sbt
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
    tmuxinator
    tmux-cssh
    tree
    unrar
    unzip
    xquartz
    xsv
    xz
    zip
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
    netcat
    openssh
    pdnsd
    rclone
    rsync
    sipcalc
    terraform
    terragrunt
    terraform-landscape
    terraform-docs
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
    pandoc
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
    #python-language-server
    solargraph
    Anki
    Dash
    Docker
    Firefox
    valgrind
    #LaunchBar # TODO: Figure out how to get past EULA
  ]
