{ pkgs }:
  with pkgs;
  let
    exe = haskell.lib.justStaticExecutables;
  in [
    (exe haskPkgs.pointful)
    (exe haskPkgs.pointfree)
    (exe haskPkgs.brittany)
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
    (exe haskPkgs.structured-haskell-mode)
    (exe haskPkgs.stylish-haskell)
    (hunspellWithDicts [hunspellDicts.en-us])
    easy-ps.purs
    easy-ps.spago
    easy-dhall.dhall-simple
    easy-dhall.dhall-json-simple
    easy-dhall.dhall-bash-simple
    darwin.iproute2mac
    jl
    ansible
    davmail
    nixStable
    nix-scripts
    nix-prefetch-scripts
    home-manager
    emacs-all-the-icons-fonts
    exercism
    du-dust
    procs
    #gnuapl
    jdk
    kotlin
    mpv
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
    #cachix
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
    #pijul
    (pass.withExtensions (ext:
      with ext;
      [ pass-otp pass-update ]))
    bat
    browserpass
    curl
    skim
    epipe
    emacs27System
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
    mtr
    nmap
    netcat
    openssh
    pdnsd
    rclone
    rsync
    sipcalc
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
    python3Packages.pygments
    solargraph
    Anki
    Dash
    Docker
    Firefox
    valgrind
    #LaunchBar # TODO: Figure out how to get past EULA
  ]
