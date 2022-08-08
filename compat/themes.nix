let
  lockFilePath = ../flake.lock;
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs.outPath = with lockFile.nodes.nixpkgs.locked;
    if type == "github" then builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; }
    else if type == "path" then builtins.path { inherit path; }
    else throw ''zonc'';

  pkgs = (import nixpkgs {
    system = builtins.currentSystem or "x86_64-linux";
  }).extend(self: _: { styx = self.callPackage ../derivation.nix {}; });
in (import ./warn.nix pkgs.lib) (import ../themes { inherit pkgs; inherit (pkgs) styx; })
