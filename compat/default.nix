let
  styxPackageRoot = "./";
  lockFilePath = "${styxPackageRoot}/flake.lock";
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs.outPath = with lockFile.nodes.nixpkgs.locked;
    if type == "github" then builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; }
    else if type == "path" then builtins.path { inherit path; }
    else throw ''zonc'';

  pkgs' = (import nixpkgs {
    system = builtins.currentSystem or "x86_64-linux";
  });
in
(import ./warn.nix pkgs'.lib)
{ themes ? []
, config ? []
, env    ? {}
, pkgs   ? pkgs' }:
(import (styxPackageRoot + ./share/lib) {inherit pkgs;).initStyx {inherit themes config env;}
