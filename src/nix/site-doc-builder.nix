let
  styxPackageRoot = "../../..";
  lockFilePath = "${styxPackageRoot}/share/styx/flake.lock";
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs.outPath = with lockFile.nodes.nixpkgs.locked;
    if type == "github" then builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; }
    else if type == "path" then builtins.path { inherit path; }
    else throw ''zonc'';
in {
  pkgs ? import nixpkgs {}
, siteFile
}: let
  site = (import siteFile) { extraConf.siteUrl = "http://domain.org"; };
in pkgs.callPackage (import ./site-doc.nix) {
  inherit (site) styx;
  site = {
    inherit (styx.themes) conf lib files templates;
    inherit (styx.themes.env) data pages;
  };
}
