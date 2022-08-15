{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.data) styxthemes;
  inherit (cell) styxlib;

  callStyxSite = siteFnOrFile: let
    call = l.customisation.callPackageWith (
      {inherit nixpkgs styxlib styxthemes;} // nixpkgs
    );
  in
    call siteFnOrFile;

  l = nixpkgs.lib // builtins;

  styxOptions = import ./styxlib/styx-options.nix {inherit inputs cell;};
in {
  inherit styxOptions callStyxSite;

  data = import ./styxlib/data.nix {inherit l nixpkgs styxlib;};
  generation = import ./styxlib/generation.nix {inherit l nixpkgs styxlib;};
  pages = import ./styxlib/pages.nix {inherit l styxlib;};
  template = import ./styxlib/template.nix {inherit l styxlib;};
  themes = import ./styxlib/themes.nix {inherit l styxlib;};
  utils = import ./styxlib/utils.nix {inherit l styxlib;};
  proplist = import ./styxlib/proplist.nix {inherit l styxlib;};
  conf = import ./styxlib/conf.nix {inherit l styxlib;};
}
