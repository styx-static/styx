{ sources ? import ./nix/sources.nix {}
, pkgs ? import sources.nixpkgs {}
, old-pkgs ? import sources.nixpkgs-old {}}:

# Use old caddy until updated to use v2 of the API.
pkgs.callPackage ./derivation.nix { caddy = old-pkgs.pkgs.caddy; }
