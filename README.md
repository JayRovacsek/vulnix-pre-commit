# vulnix-pre-commit
A simple wrapper for vulnix to check the state of a flake derivation for new or introduced vulnerabilities

# !!!WARNING!!!
This flake does not currently achieve exactly what it suggests on the box - the hook utilised to identify is any vulnerability of
X severity or above uses the `--system` flag for the moment until I can rewrite the location checks a bit more intelligently.
Pull requests welcome! :heart:

## Developing This Flake
To contribute to this flake, please create a meaningful pull request against the repository. If you are utilising
a visual studio code derivative you should be able to include the dev shell within your environment with the use of 
this extension: 
```
Name: Nix Environment Selector
Id: arrterian.nix-env-selector
Description: Allows switch environment for Visual Studio Code and extensions based on Nix config file.
Version: 1.0.9
Publisher: arrterian
```

## Goals Of This Flake
The goal of this flake is to provide a method in which vulnix can be utilised to assess the build output of a flake 
for vulnerabilities.

## Utilisation
This flake leverages [Cachix's pre-commit-hooks repository](https://github.com/cachix/pre-commit-hooks.nix); firstly add it
to your project then you should be able to use the following structure (or an alike one) to determine if the default
build outputs of your project are weak to a select severity of vulnerability. Note that this is currently limited scope and 
intent to augment this capability to be a little smarter about determining if changes have meaningfully eroded the security
of a build are not yet fully realised (see the future section below).

MVP Flake structure:
```nix
{
  description = "";

  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    vulnix-pre-commit.url = "github:jayrovacsek/vulnix-pre-commit";

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url =
        "github:cachix/pre-commit-hooks.nix/a8f7e8c2f2c8a428e2844c99ee5aa4718db61698";
      inputs = {
        nixpkgs.follows = "stable";
        flake-utils.follows = "flake-utils";
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
        checks = {
          pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run
            (import ./pre-commit-checks.nix { inherit self pkgs system; });
        };

        devShell = pkgs.mkShell {
          name = "soe-dev-shell";
          packages = devShellStableDeps ++ devShellUnstableDeps;
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
        devShells.default = self.outputs.devShell.${system};
      in { inherit devShell devShells checks; });
}
```

MVP pre-commit-checks structure:
```nix
{ self, pkgs, system }: {
  src = self;
  hooks = {
    vulnix = {
      enable = true;
      name = "Vulnix Spicy CVE Check";
      entry = "${
          self.inputs.vulnix-pre-commit.packages.${system}.vulnix-pre-commit
        }/bin/vulnix-pre-commit 7.5";

      language = "system";
    };
  };
}
```

## Future
The future of this project would incorporate the following to the current functionality:

### Diverse CVE Filters
Currently we only apply a CVE severity threshold: it would be preferable that this is configurable so that other elements of 
the detections can be utilised more contextually.

### Deduplication Of CVEs
Current implementation is naive and inefficient - there is current work to resolve this from occurring. As my current use-case
is either single system assessment or package assessment this is not problematic from a computation perspective but certainly is
not going to be appropriate long-term.

### Known Exploitability Application
Stopping CVEs from existing is a lofty goal, however not all CVEs have known exploitation. While CVSSv3 includes this as a component
of scoring under temporal elements, we may want to apply a pre-filter (optionally) if the exploit of a CVE is unproven to reduce 
overhead for a responder. For now this could also be considered an element of `Diverse CVE Filters`