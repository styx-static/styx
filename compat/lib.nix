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
in
_: let

  inherit (import ../src/default.nix { inherit pkgs; }) lib;
  loadDecls = cs:
    let
      f = c:
        if   lib.utils.isPath c
        then lib.utils.importApply c { inherit lib; }
        else c;
    in lib.utils.merge (map f cs);

in (import ./warn.nix lib) lib // {
  themes = lib.themes // {
    load = lib.themes.load // {
      function = { styxLib, extraConf ? [], extraEnv ? {}, themes ? [] }: lib.themes.load.function {
        inherit themes;
        lib = styxLib;
        env = extraEnv;
        decls = loadDecls extraConf;
      };
    };
    loadData = lib.themes.loadData // {
      function = { theme, styxLib }: lib.themes.load.function {
        inherit theme;
        lib = styxLib;
      };
    };
  };
}

