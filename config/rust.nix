self: {
    extensions = [
      "rust-src"
      "rust-analysis"
    ];
    targets = [
      "x86_64-unknown-linux-gnu"
    ];
    targetExtensions = self.extensions;
  }
