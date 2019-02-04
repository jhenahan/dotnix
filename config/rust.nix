self: {
    extensions = [
      "rust-src"
      "rust-analysis"
      "rls-preview"
    ];
    targets = [
      "x86_64-unknown-linux-gnu"
    ];
    targetExtensions = self.extensions;
  }
