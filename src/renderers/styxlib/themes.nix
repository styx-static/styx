{
  l,
  styxlib,
}: let
  inherit (styxlib) utils;

  /*
  Recursively fetches a directory of templates
  return a recursive set of { NAME = FILE }
  */
  fetchTemplateDir = dir: let
    f = path: dir:
      l.mapAttrs' (
        k: v: let
          nixFile = l.match "^(.+)\.nix$" k;
        in
          if v == "directory"
          then l.nameValuePair k (f (path ++ [dir]) (dir + "/${k}"))
          else if nixFile != null
          then l.nameValuePair (l.elemAt nixFile 0) (dir + "/${k}")
          # non-nix files
          else l.nameValuePair k null
      )
      (l.readDir dir);
    # removing any non-nix files
    cleanup = l.filterAttrsRecursive (n: v: v != null);
  in
    cleanup (f [dir] dir);

  /*
  find a file in a theme
  return null if not found
  */
  findInTheme = t: f:
    if utils.dirContains t.path f
    then t.path + "/${f}"
    else null;
in {
  /*
  ===============================================================

   load

  ===============================================================
  */

  load = utils.documentedFunction {
    description = ''
      Load themes data.
    '';

    arguments = {
      themes = {
        description = "List of themes, local themes or packages.";
        type = "[ (Path | Package) ]";
        default = {};
      };
      decls = {
        description = "A declaration set to merge into to themes configuration.";
        type = "Attrs";
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
      * `l`: The nixpkgs.lib library merged with builtins.
      * `styxlib`: The merged themes library.
      * `lib`: The merged themes library.
      * `files`: List of static files folder.
      * `templates`: The merged themes template set.
      * `themes`: List of themes attribute sets.
      * `decls`: Themes declaration set.
      * `docs`: Themes documentation set.
      * `env`: Generated environment attribute set, `extraEnv` merged with `lib`, `conf` and `templates`.
    '';

    examples = [
      (utils.mkExample {
        literalCode = ''
          themesData = styxlib.themes.load {
            inherit themes;
            env  = { inherit data pages; };
            decls = utils.merge [
              (import ./conf.nix {/* ... */})
              extraConf
            ];
          };
        '';
      })
    ];

    function = {
      themes ? [],
      config ? [],
      env ? {},
    }: let
      decls = styxlib.conf.mergeConfs ([styxlib.styxOptions] ++ config);
      root = styxlib.conf.parseDecls {
        inherit decls;
        optionFn = o:
          if o ? default
          then o.default
          else null;
      };
      theme = styxlib.conf.parseDecls {
        decls = decls';
        optionFn = o:
          if o ? default
          then o.default
          else null;
      };

      data = styxlib.data {config = root;};
      evaledStyxlib = styxlib // {inherit data;};

      themesData = map (theme:
        styxlib.themes.loadData {
          inherit theme;
          lib = lib'; # FIXME: split into l & styxlib
        })
      themes;
      # supercharge `lib` with everything on this planet
      styxlib' = utils.merge ([evaledStyxlib] ++ (l.catAttrs "lib" themesData));
      lib' = utils.merge [l styxlib'];
      decls' = utils.merge (l.catAttrs "decls" themesData);
      docs = utils.merge (l.catAttrs ["docs"] themesData);
      files = l.catAttrs "files" themesData;

      conf' = let
        typeCheckResult =
          if theme
          then styxlib.conf.typeCheck decls' theme
          else null;
        merged = utils.merge [{inherit theme;} root];
      in
        l.deepSeq typeCheckResult merged;

      env' =
        env
        // {
          # always prefer explicitly specified values
          l = env.l or l;
          styxlib = env.styxlib or styxlib';
          lib = env.lib or lib';
          conf = env.conf or conf';
          templates = env.templates or templates';
        };

      templates' = let
        templatesSet = utils.merge (l.catAttrs "templates" themesData);
      in
        l.mapAttrsRecursive (path: template: template env') templatesSet;
    in {
      inherit docs files l;
      styxlib = styxlib';
      lib = lib';
      decls = decls';
      env = env';
      conf = conf';
      templates = templates';
      themes = themesData;
    };
  };

  /*
  ===============================================================

   loadData

  ===============================================================
  */

  loadData = utils.documentedFunction {
    description = ''
      Load a theme data.
    '';

    arguments = {
      lib = {
        description = "The styx library.";
        type = "Attrs";
      };
      theme = {
        description = "A local theme or theme package.";
        type = "(Path | Package)";
      };
    };

    return = ''
      A theme data attribute set containing:

      * `lib`: Theme library set.
      * `meta`: Theme meta information set.
      * `path`: Path of the theme.
      * `decls`: Theme declaration set, only if the theme defines a configuration interface.
      * `docs`: Theme documentation set, only if the theme defines a configuration interface.
      * `exampleSrc`: Theme example site source, only if the theme provides an example site.
      * `templates`: Theme templates set, only if the theme provides templates.
      * `files`: Theme static files path, only if the theme provides static files.

    '';

    function = {
      theme,
      lib,
    }: let
      confFile = findInTheme {path = theme;} "conf.nix";
      libFile = findInTheme {path = theme;} "lib.nix";
      filesDir = findInTheme {path = theme;} "files";
      templatesDir = findInTheme {path = theme;} "templates";
      exampleFile = findInTheme {path = theme;} "example/site.nix";
      arg = {inherit lib;};
      meta = utils.importApply (theme + "/meta.nix") arg;
    in
      {
        # meta information
        meta = {name = meta.id;} // meta;
        # id
        id = meta.id;
        # path
        path = l.toPath theme;
      }
      # function library
      // l.optionalAttrs (libFile != null)
      {lib = utils.importApply libFile arg;}
      # configuration interface declarations and documentation
      // (l.optionalAttrs (confFile != null)
        rec {
          decls = utils.importApply confFile arg;
          docs = styxlib.themes.mkDoc decls;
        })
      // (l.optionalAttrs (exampleFile != null)
        {exampleSrc = l.readFile exampleFile;})
      // (l.optionalAttrs (templatesDir != null)
        {templates = l.mapAttrsRecursive (path: value: import value) (fetchTemplateDir templatesDir);})
      // (l.optionalAttrs (filesDir != null)
        {files = filesDir;});
  };

  /*
  ===============================================================

   mkDoc

  ===============================================================
  */

  mkDoc = utils.documentedFunction {
    description = ''
      Convert a theme declaration set to a documentation set.
    '';

    arguments = [
      {
        name = "decls";
        description = "Theme declarations set.";
        type = "Attrs";
      }
    ];

    return = "A documentation set.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.themes.mkDoc {
            foo.bar = 1;
            title = l.mkOption {
              description = "Title";
              type = l.types.str;
            };
          }
        '';
        code = styxlib.themes.mkDoc {
          title = l.mkOption {
            description = "Title";
            type = l.types.str;
          };
          foo.bar = 1;
        };
        expected = {
          foo.bar = {
            _type = "option";
            default = 1;
          };
          title = {
            _type = "option";
            description = "Title";
            type = "string";
          };
        };
      })
    ];

    function = decls:
      styxlib.conf.parseDecls {
        inherit decls;
        optionFn = o:
          o
          // (
            if o ? type
            then {type = o.type.description;}
            else {}
          );
        valueFn = v: l.mkOption {default = v;};
      };
  };

  /*
  ===============================================================

   docText

  ===============================================================
  */

  docText = utils.documentedFunction {
    description = "Convert a documentation set to a property list to generate documention.";

    arguments = [
      {
        name = "doc";
        description = "Documentation set.";
        type = "Attrs";
      }
    ];

    return = "A prepared documentation property list.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.themes.docText (styxlib.themes.mkDoc {
            title = l.mkOption {
              description = "Title";
              type = l.types.str;
            };
            foo.bar = 1;
          })
        '';
        code = styxlib.themes.docText (styxlib.themes.mkDoc {
          title = l.mkOption {
            description = "Title";
            type = l.types.str;
          };
          foo.bar = 1;
        });
        expected = [
          {
            "foo.bar" = {
              default = 1;
            };
          }
          {
            title = {
              description = "Title";
              type = "string";
            };
          }
        ];
      })
    ];

    function = docSet: let
      f = path: set:
        map (
          key: let
            value = set.${key};
            newPath = path ++ [key];
            pathString = l.concatStringsSep "." newPath;
          in
            if l.isOption value
            then {"${pathString}" = l.removeAttrs value ["_type"];}
            else if l.isAttrs value
            then f newPath value
            else {"${pathString}" = value;}
        ) (l.attrNames set);
    in
      l.flatten (f [] docSet);
  };
}
