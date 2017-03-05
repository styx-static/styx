# themes

lib:
with lib;
with import ./utils.nix lib;
with import ./conf.nix lib;
with import ./proplist.nix lib;

let
  /* Recursively fetches a directory of templates
     return a recursive set of { NAME = FILE }
  */
  fetchTemplateDir = dir:
    let
      f = path: dir:
        mapAttrs' (k: v:
          let
            nixFile = match "^(.+)\.nix$" k;
          in
          if v == "directory"
             then nameValuePair k (f (path ++ [ dir ]) (dir + "/${k}"))
             else if nixFile != null then nameValuePair (elemAt nixFile 0) (dir + "/${k}")
             # non-nix files
             else nameValuePair k null
        )
        (readDir dir);
      # removing any non-nix files
      cleanup = filterAttrsRecursive (n: v: v != null);
    in
      cleanup (f [ dir ] dir);

  /* find a file in a theme
     return null if not found
  */
  findInTheme = t: f: if dirContains t.path f then t.path + "/${f}" else null;

  /* extract an attribute key from a list of theme and remove null values
  */
  getThemesAttr = themes: attr: (map (x: getAttr attr x) (filter (x: hasAttr attr x) themes));

in
rec {

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
      styxLib = {
        description = "The styx library.";
        type = "Attrs";
      };
      themes = {
        description = "List of themes, local themes or packages.";
        type = "[ (Path | Package) ]";
        default = {};
      };
      "extraConf" = {
        description = "A list of configuration attribute sets or configuration files to merge to themes configuration.";
        type = "[ Attrs ]";
        default = [];
      };
      "extraEnv" = {
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
      * `env`: Generated environment attribute set, `extraEnv` merged with `lib`, `conf` and `template`.
    '';

    examples = [ (mkExample {
      literalCode = ''
        themesData = styxLib.themes.load {
          inherit styxLib themes;
          extraEnv  = { inherit data pages; };
          extraConf = [ ./conf.nix extraConf ];
        };
      '';
    }) ];

    function = {
      styxLib
    , themes ? []
    , extraConf ? []
    , extraEnv ? {}
    }:
    let
      themesData = map (theme: loadData { inherit theme styxLib; }) themes;

      decls = styxLib.utils.merge (getThemesAttr themesData "decls");

      docs = styxLib.utils.merge (getThemesAttr themesData "docs");

      lib = styxLib.utils.merge ([ styxLib ] ++ (getThemesAttr themesData "lib"));

      files = getThemesAttr themesData "files";

      conf' =
        let
          isPath     = x: ( ! isAttrs x ) && styxLib.types.path.check x;
          extraConf' = map (c: if isPath c then importApply c { inherit lib; } else c) extraConf;
          defaults   = styxLib.utils.merge extraConf';
          themesDefaults.theme = parseDecls { inherit decls; optionFn = o: if o ? default then o.default else null; };
          typeCheckResult = if defaults ? theme
                            then styxLib.conf.typeCheck decls defaults.theme
                            else null;
        in deepSeq typeCheckResult (styxLib.utils.merge [ themesDefaults defaults ]);

      env = extraEnv // {
        inherit lib;
        conf      = conf';
        templates = templates';
      };

      templates' =
        let
          templatesSet = styxLib.utils.merge (getThemesAttr themesData "templates");
        in mapAttrsRecursive (path: template:
          template env
        ) templatesSet;

      themesSet = fold (t: acc:
        acc // { "${t.id}" = t; }
      ) {} themesData;

    in
    {
      inherit decls docs lib files env;
      conf      = conf';
      templates = templates';
      themes    = themesData;
    };
  };


/*
===============================================================

 loadData

===============================================================
*/

  loadData = documentedFunction {
    description = ''
      Load a theme data.
    '';

    arguments = {
      styxLib = {
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
      theme
    , styxLib
    }:
      let
        confFile     = findInTheme { path = theme; } "conf.nix";
        libFile      = findInTheme { path = theme; } "lib.nix";
        filesDir     = findInTheme { path = theme; } "files";
        templatesDir = findInTheme { path = theme; } "templates";
        exampleFile  = findInTheme { path = theme; } "example/site.nix";
        lib          = optionalAttrs (libFile != null) (importApply libFile { lib = styxLib; });
        fullLib      = styxLib.utils.merge [ styxLib lib ];
        arg          = { lib = fullLib; };
        meta         = importApply (theme + "/meta.nix") arg;
      in {
        # function library
        inherit lib;
        # meta information
        meta  = { name = meta.id; } // meta;
        # id
        id    = meta.id;
        # path
        path  = toPath theme;
      }
      # configuration interface declarations and documentation
      // (optionalAttrs (confFile != null)
           rec { decls = importApply confFile arg; docs = mkDoc decls; })
      // (optionalAttrs (exampleFile != null)
           { exampleSrc = readFile exampleFile; })
      // (optionalAttrs (templatesDir != null)
           { templates = (mapAttrsRecursive (path: value: import value) (fetchTemplateDir templatesDir)); })
      // (optionalAttrs (filesDir != null)
           { files = filesDir; });

  };


/*
===============================================================

 mkDoc

===============================================================
*/

  mkDoc = documentedFunction {
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

    examples = [ (mkExample {
      literalCode = ''
        mkDoc {
          foo.bar = 1;
          title = mkOption {
            description = "Title";
            type = types.str;
          };
        }
      '';
      code =
        mkDoc {
          title = mkOption {
            description = "Title";
            type = types.str;
          };
          foo.bar = 1;
        }
      ;
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
    }) ];

    function = decls: parseDecls {
      inherit decls;
      optionFn = (o: o // (if o ? type then { type = o.type.description; } else {}));
      valueFn  = (v: mkOption { default = v; });
    };
  };


/*
===============================================================

 docText

===============================================================
*/

  docText = documentedFunction {
    description = "Convert a documentation set to a property list to generate documention.";

    arguments = [
      {
        name = "doc";
        description = "Documentation set.";
        type = "Attrs";
      }
    ];

    return = "A prepared documentation property list.";

    examples = [ (mkExample {
      literalCode = ''
        docText (mkDoc {
          title = mkOption {
            description = "Title";
            type = types.str;
          };
          foo.bar = 1;
        })
      '';
      code =
        docText (mkDoc {
          title = mkOption {
            description = "Title";
            type = types.str;
          };
          foo.bar = 1;
        })
      ;
      expected = [ {
        "foo.bar" = {
          default = 1;
        };
      } {
        title = {
          description = "Title";
          type = "string";
        };
      } ];
    }) ];

    function = docSet:
      let
      f = path: set:
        map (key:
          let
            value = set.${key};
            newPath = path ++ [ key ];
            pathString = concatStringsSep "." newPath;
          in
          if isOption value
             then { "${pathString}" = removeAttrs value [ "_type" ]; }
          else if isAttrs value
             then f newPath value
             else { "${pathString}" = value; }
        ) (attrNames set);
      in flatten (f [] docSet);
  };

}
