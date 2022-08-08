let
  lockFilePath = ../flake.lock;
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs.outPath = with lockFile.nodes.nixpkgs.locked;
    if type == "github" then builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; }
    else if type == "path" then builtins.path { inherit path; }
    else throw ''zonc'';
in
{
  pkgs ? import nixpkgs {}
, styx ? pkgs.callPackage ../derivation.nix {}
}:

  pkgs.lib.mapAttrs (n: v: let
    themeSrc = pkgs.fetchFromGitHub v;
    pkgsWithStyx = pkgs // {inherit styx;};
  in pkgs.lib.callPackageWith pkgsWithStyx themeSrc {}) (import ./versions.nix)
