{ self, pkgs, system }: {
  src = self;
  hooks = {
    nixfmt.enable = true;
    statix.enable = true;
  };
}
