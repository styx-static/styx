{ sources ? import ./nix/sources.nix {}
, pkgs ? import sources.nixpkgs {} }:

pkgs.callPackage ./derivation.nix {}
