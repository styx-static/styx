{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.data) styxthemes;
  inherit (inputs.cells.app.cli) styx;

  callStyxSite = siteFnOrFile: let
    call = l.customisation.callPackageWith (
      nixpkgs.extend (_: _: {inherit styx;})
    );
  in
    call siteFnOrFile;

  l = nixpkgs.lib // builtins;

  styxOptions = import ./styxlib/styx-options.nix {inherit inputs cell;};

  compat = prev: final: (l.mapAttrs
    (n:
      l.warn ''

        The non fully qualified accessor 'styxlib.${n}' is deprecated.
        FQN: ${
          if l.hasAttr n final.data
          then "styxlib.data.${n}"
          else if l.hasAttr n final.generation
          then "styxlib.generation.${n}"
          else if l.hasAttr n final.pages
          then "styxlib.pages.${n}"
          else if l.hasAttr n final.template
          then "styxlib.template.${n}"
          else if l.hasAttr n final.themes
          then "styxlib.themes.${n}"
          else if l.hasAttr n final.utils
          then "styxlib.utils.${n}"
          else if l.hasAttr n final.proplist
          then "styxlib.proplist.${n}"
          else if l.hasAttr n final.conf
          then "styxlib.conf.${n}"
          else if l.hasAttr n l
          then "styxlib.lib.${n}"
          else "couldn't find origin"
        }
      '')
    (
      {
        base = l;
      }
      // final.lib # keep here for evtl overrides
      // final.data
      // final.generation
      // final.pages
      // final.template
      // final.themes
      // final.utils
      // final.proplist
      // final.conf
    ));

  res = l.makeExtensibleWithCustomName "_hydrate" (self: {
    hydrate = f: res._hydrate (l.composeExtensions f compat);

    config = throw ''

      A library function call depends on the second init stage.

      ---------------------------------------------------------

      The Styx Library ('styxlib') has 2 initialization stages.

      The first stage can be used previous to initializing
      the custom configuration ('styxlib.config').

      For any library function, however, that depends on the
      custom library configuration, the second stage must be
      initialized.

      To inizialize the second stage:
        - normally load a site via 'styxlib.themes.load'
        - exceptionally initialize via
          'styxlib.hydrate (_: _: { config = evaledStyxConfig; })'
    '';

    inherit styxOptions callStyxSite;

    lib = l;

    data = import ./styxlib/data.nix l nixpkgs {
      inherit
        (self)
        utils
        proplist
        config
        ;
    };
    generation = import ./styxlib/generation.nix l nixpkgs {
      inherit
        (self)
        utils
        ;
    };
    pages = import ./styxlib/pages.nix l {
      inherit
        (self)
        utils
        proplist
        ;
    };
    template = import ./styxlib/template.nix l {
      inherit
        (self)
        utils
        ;
    };
    themes =
      import ./styxlib/themes.nix l {
        inherit
          (self)
          utils
          proplist
          conf
          ;
      }
      // (import ./styxlib/load-themes.nix l nixpkgs self);
    utils = import ./styxlib/utils.nix l;
    proplist = import ./styxlib/proplist.nix l {
      inherit
        (self)
        utils
        ;
    };
    conf = import ./styxlib/conf.nix l nixpkgs {
      inherit
        (self)
        utils
        ;
    };
  });
in
  res.hydrate (_: _: {})
