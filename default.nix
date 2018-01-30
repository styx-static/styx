{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./derivation.nix {
  withEmacs = true;
    emacspkg = pkgs.emacsWithPackages
      (epkgs: (with epkgs.melpaPackages; with epkgs.orgPackages; [
      use-package
      org-plus-contrib
      htmlize
    ]));
}
