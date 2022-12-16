{ pkgs }:
with pkgs; {
  vulnix-pre-commit = callPackage ./vulnix-pre-commit { };
}
