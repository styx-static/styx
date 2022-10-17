# themes
lib: nixpkgs: styxlib:
with lib;
# assert assertMsg (hasAttr "utils" styxlib) "styxlib.load-themes uses styxlib.utils";
# assert assertMsg (hasAttr "conf" styxlib) "styxlib.load-themes uses styxlib.conf";
# assert assertMsg (hasAttr "themes" styxlib) "styxlib.load-themes uses styxlib.themes";
with styxlib.utils;
with styxlib.conf;
with styxlib.themes; {
  /*
  ===============================================================

   mergeConfs

  ===============================================================
  */

  mergeConfs = documentedFunction {
    description = ''
      Merge a list of configurations.
    '';

    arguments = [
      {
        name = "confs";
        description = "List of configurations.";
        type = "[ Attrs | Path ]";
      }
    ];

    return = ''
      The merged configuration set.
    '';

    function = confs:
      merge (map (c:
        if isPath c
        then
          importApply c {
            pkgs = nixpkgs;
            lib = styxlib; # load entire (second stage) styxlib
          }
        else c)
      confs);
  };

  /*
  ===============================================================

   load

  ===============================================================
  */

  load = documentedFunction {
    description = ''
      Load themes data.
    '';

    arguments = {
      lib = {
        description = "The styx library.";
        type = "Attrs";
      };
      themes = {
        description = "List of themes, local themes or packages.";
        type = "[ (Path | Package) ]";
        default = {};
      };
      config = {
        description = "List of configuration or paths to configuration.";
        type = "[ (Attrs | Path) ]";
        default = [];
      };
      env = {
        description = "An attribute set to merge to the environment, the environment is used in templates and returned in the `env` attribute.";
        type = "Attrs";
        default = {};
      };
    };

    return = ''
      A theme data attribute set containing:

      * `conf`: Themes configuration merged with `extraConf`.
      * `lib`: The merged themes library.
      * `files`: List of static files folder.
      * `templates`: The merged themes template set.
      * `themes`: List of themes attribute sets.
      * `decls`: Themes declaration set.
      * `docs`: Themes documentation set.
      * `env`: Generated environment attribute set, `extraEnv` merged with `lib`, `conf` and `templates`.
    '';

    examples = [
      (mkExample {
        literalCode = ''
          themesData = lib.themes.load {
            inherit lib themes;
            env  = { inherit data pages; };
            decls = lib.utils.merge [
              (import ./conf.nix {/* ... */})
              extraConf
            ];
          };
        '';
      })
    ];

    function = {
      lib,
      themes ? [],
      config ? [],
      env ? {},
    }: let
      # use secondStageStyxlib to make things like loadFile available
      # in a site's / theme's 'conf.nix' file
      decls = secondStageStyxlib.themes.mergeConfs ([lib.styxOptions] ++ config);
      root = parseDecls {
        inherit decls;
        optionFn = o:
          if o ? default
          then o.default
          else null;
      };
      secondStageStyxlib = styxlib.hydrate (_: _: {config = root;});

      themesData =
        map (theme: loadData {inherit theme lib;})
        themes;
      lib' = merge ([secondStageStyxlib] ++ (catAttrs "lib" themesData));
      decls' = merge (catAttrs "decls" themesData);
      docs = merge (catAttrs "docs" themesData);
      files = catAttrs "files" themesData;

      conf' = let
        theme = parseDecls {
          decls = decls';
          optionFn = o:
            if o ? default
            then o.default
            else null;
        };
        typeCheckResult =
          if theme != {}
          then typeCheck decls' theme
          else null;
        merged = merge [{inherit theme;} root];
      in
        deepSeq typeCheckResult merged;

      env' =
        env
        // {
          # always prefer explicitly specified values
          lib = env.lib or lib';
          conf = env.conf or conf';
          templates = env.templates or templates';
        };

      templates' = let
        templatesSet = merge (catAttrs "templates" themesData);
      in
        mapAttrsRecursive (path: template: template env') templatesSet;
    in {
      inherit docs files;
      lib = lib';
      decls = decls';
      env = env';
      conf = conf';
      templates = templates';
      themes = themesData;
    };
  };
}
