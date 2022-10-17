# themes
lib: styxlib:
with lib;
assert assertMsg (hasAttr "utils" styxlib) "styxlib.themes uses styxlib.utils";
assert assertMsg (hasAttr "proplist" styxlib) "styxlib.themes uses styxlib.proplist";
assert assertMsg (hasAttr "conf" styxlib) "styxlib.themes uses styxlib.conf";
with styxlib.utils;
with styxlib.proplist;
with styxlib.conf; let
  /*
  Recursively fetches a directory of templates
  return a recursive set of { NAME = FILE }
  */
  fetchTemplateDir = dir: let
    f = path: dir:
      mapAttrs' (
        k: v: let
          nixFile = match "^(.+)\.nix$" k;
        in
          if v == "directory"
          then nameValuePair k (f (path ++ [dir]) (dir + "/${k}"))
          else if nixFile != null
          then nameValuePair (elemAt nixFile 0) (dir + "/${k}")
          # non-nix files
          else nameValuePair k null
      )
      (readDir dir);
    # removing any non-nix files
    cleanup = filterAttrsRecursive (n: v: v != null);
  in
    cleanup (f [dir] dir);

  /*
  find a file in a theme
  return null if not found
  */
  findInTheme = t: f:
    if dirContains t.path f
    then t.path + "/${f}"
    else null;
in rec {
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
      meta = importApply (theme + "/meta.nix") arg;
    in
      {
        # meta information
        meta = {name = meta.id;} // meta;
        # id
        inherit (meta) id;
        # path
        path = /. + "${toString theme}";
      }
      # function library
      // optionalAttrs (libFile != null)
      {lib = importApply libFile arg;}
      # configuration interface declarations and documentation
      // (optionalAttrs (confFile != null)
        rec {
          decls = importApply confFile arg;
          docs = mkDoc decls;
        })
      // (optionalAttrs (exampleFile != null)
        {exampleSrc = readFile exampleFile;})
      // (optionalAttrs (templatesDir != null)
        {templates = mapAttrsRecursive (path: import) (fetchTemplateDir templatesDir);})
      // (optionalAttrs (filesDir != null)
        {files = filesDir;});
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

    examples = [
      (mkExample {
        literalCode = ''
          mkDoc {
            foo.bar = 1;
            title = mkOption {
              description = "Title";
              type = types.str;
            };
          }
        '';
        code = mkDoc {
          title = mkOption {
            description = "Title";
            type = types.str;
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
      parseDecls {
        inherit decls;
        optionFn = o:
          o
          // (
            if o ? type
            then {type = o.type.description;}
            else {}
          );
        valueFn = v: mkOption {default = v;};
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

    examples = [
      (mkExample {
        literalCode = ''
          docText (mkDoc {
            title = mkOption {
              description = "Title";
              type = types.str;
            };
            foo.bar = 1;
          })
        '';
        code = docText (mkDoc {
          title = mkOption {
            description = "Title";
            type = types.str;
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
            pathString = concatStringsSep "." newPath;
          in
            if isOption value
            then {"${pathString}" = removeAttrs value ["_type"];}
            else if isAttrs value
            then f newPath value
            else {"${pathString}" = value;}
        ) (attrNames set);
    in
      flatten (f [] docSet);
  };
}
