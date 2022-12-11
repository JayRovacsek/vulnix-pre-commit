{
  description = "Vulnix pre-commit hook";

  inputs = rec {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    stable.url = "github:nixos/nixpkgs/release-22.11";
    unstable = nixpkgs;

    # Adds flake compatability to start removing the vestiges of 
    # shell.nix and move us towards the more modern nix develop
    # setting while tricking some services/plugins to still be able to
    # use the shell.nix file.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "stable";
    };

    # Adds configurable pre-commit options to our flake :)
    pre-commit-hooks = {
      url =
        "github:cachix/pre-commit-hooks.nix/a8f7e8c2f2c8a428e2844c99ee5aa4718db61698";
      inputs = {
        nixpkgs.follows = "stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
        gitignore.follows = "stable";
      };
    };
  };

  outputs = { self, flake-utils, ... }:
    flake-utils.lib.eachSystem [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ] (system:
      let
        # Note that the below use of pkgs will by implication mean that
        # our dev dependencies for local packages as well as part of our
        # devShell are pinned to stable - this is intended to ensure
        # backwards compatability & reduced pain when managing deps
        # in these spaces
        pkgs = self.inputs.stable.legacyPackages.${system};
        pkgsUnstable = self.inputs.unstable.legacyPackages.${system};

        devShellStableDeps = with pkgs; [ nixfmt statix vulnix nil ];
        devShellUnstableDeps = with pkgsUnstable; [ ];

        checks = {
          pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run
            (import ./pre-commit-checks.nix { inherit self pkgs system; });
        };

        devShell = pkgs.mkShell {
          name = "nix-config-dev-shell";
          packages = devShellStableDeps ++ devShellUnstableDeps;
          # Self reference to make the default shell hook that which generates
          # a suitable pre-commit hook installation
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        # Self reference the dev shell for our system to resolve the lacking
        # devShells.${system}.default recommended structure
        devShells.default = self.outputs.devShell.${system};

        # Import local packages passing system relevnet pkgs through
        # for dependencies.
        localPackages = import ./packages { inherit pkgs; };
        localUnstablePackages = import ./packages { pkgs = pkgsUnstable; };
        packages = (flake-utils.lib.flattenTree localPackages) // {
          default = self.outputs.packages.${system}.vulnix-precommit;
        };
        unstablePackages = flake-utils.lib.flattenTree localUnstablePackages;
      in { inherit devShell devShells packages unstablePackages checks; });
}
