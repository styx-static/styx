let
  lockFilePath = ../flake.lock;
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  nixpkgs.outPath = with lockFile.nodes.nixpkgs.locked;
    if type == "github" then builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; }
    else if type == "path" then builtins.path { inherit path; }
    else throw ''zonc'';

  themes = {
    styx-theme-generic-templates = with.lockFile.nodes.styx-theme-generic-templates.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
    styx-theme-hyde = with.lockFile.nodes.styx-theme-hyde.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
    styx-theme-orbit = with.lockFile.nodes.styx-theme-orbit.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
    styx-theme-agency = with.lockFile.nodes.styx-theme-agency.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
    styx-theme-showcase = with.lockFile.nodes.styx-theme-showcase.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
    styx-theme-nix = with.lockFile.nodes.styx-theme-nix.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
    styx-theme-ghostwriter = with.lockFile.nodes.styx-theme-ghostwriter.locked;
      builtins.fetchTarball { url = "https://github.com/repos/${owner}/${repo}/${rev}"; sha256 = narHash; };
  };

  pkgs = (import nixpkgs {
    system = builtins.currentSystem or "x86_64-linux";
  }).extend(self: _: { styx = self.callPackage ../derivation.nix {}; });
in (import ./warn.nix pkgs.lib) pkgs.lib.mapAttrs (n: v: pkgs.callPackage v {}) themes;

