let
  flake = builtins.getFlake (toString ./.);
  deSystemize = flake.inputs.std.deSystemize builtins.currentSystem;

  l = inp.nixpkgs.lib;
  pretty = l.generators.toPretty {};

  inp = builtins.mapAttrs (_: deSystemize) flake.inputs;
  out = flake.${builtins.currentSystem};
in
  l.trace "inp: ${pretty (l.attrNames inp)}"
  l.trace "out: ${pretty (l.mapAttrs (_: l.mapAttrs (_: _: "...")) out)}"
  {inherit inp out;}
