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
  findInTheme = t: f:
    if dirContains t.path f then t.path + "/${f}" else null;

  /* extract an attribute key from a list of theme and remove null values
  */
  getThemesAttr = themes: attr: (filter (x: x != null) (map (t: t."${attr}") themes)) ;

in
rec {

  /* Load themes related files

     returns an attribute set containing:

       - conf: the loaded configuration set
       - lib: the loaded lib
       - files: the loaded static files paths
       - templates: the loaded templates attribute set
       - themes: themes information attribute set

     This is mainly a wrapper to the other lib.themes.load* functions
  */
  load = {
  # styx library
    styxLib
  # list of themes as path or packages
  , themes ? []
  # configuration loading arguments
  , conf ? {}
  # templates loading arguments
  , templates ? {}
  }:
  let
    themesData = map (theme: loadData { inherit theme styxLib; }) themes;
    decls = styxLib.utils.merge (getThemesAttr themesData "decls");

    lib = styxLib.utils.merge ([ styxLib ] ++ (getThemesAttr themesData "lib"));

    files = getThemesAttr themesData "files";

    themes' = fold (t: acc:
      acc // { "${t.id}" = t; }
    ) {} themesData;

    conf' = 
      let
        isPath     = x: ( ! isAttrs x ) && styxLib.types.path.check x;
        extraConf  = map (c: if isPath c then importApply c { inherit lib; } else c) (conf.extra or []);
        defaults   = styxLib.utils.merge extraConf;
        themesDefaults.theme  = parseDecls { inherit decls; optionFn = o: if o ? default then o.default else null; };
        typeCheckResult = if defaults ? theme
                          then styxLib.conf.typeCheck decls defaults.theme
                          else null;
      in deepSeq typeCheckResult (styxLib.utils.merge [ themesDefaults defaults ]);

    templates' =
      let
        environment = (templates.extraEnv or {}) // {
          inherit lib;
          conf      = conf';
          templates = templates';
        };
        templatesSet = styxLib.utils.merge (getThemesAttr themesData "templates");
      in mapAttrsRecursive (path: template:
        template environment
      ) templatesSet;
  in
  {
    inherit decls lib files;
    conf      = conf';
    templates = templates';
    themes    = themes';
  };
  
  /* Load theme information, return a set with the following keys:

     
     - lib: function library
     - meta: meta information
     - id: id
     - path: path
     - decls: configuration interface declarations
     - defs: configuration interfaces definition
     - docs: configuration interface documentation
     - templates: templates functions, environment not applied
     - files: static files

  */
  loadData = {
    theme
  , styxLib
  }:
    let
      confFile     = findInTheme { path = theme; } "conf.nix";
      libFile      = findInTheme { path = theme; } "lib.nix";
      filesDir     = findInTheme { path = theme; } "files";
      templatesDir = findInTheme { path = theme; } "templates";
      arg = { lib = fullLib; };
      lib   = if   libFile != null
              then (importApply libFile { lib = styxLib; })
              else null;
      fullLib = styxLib.utils.merge [ styxLib (if lib != null then lib else {}) ];
    in rec {
      # function library
      inherit lib;
      # meta information
      meta  = importApply (theme + "/meta.nix") arg;
      # id
      id    = meta.id;
      # path
      path  = toPath theme;
      # configuration interface declarations
      decls = if   confFile != null
              then importApply confFile arg
              else null;
      # templates functions, environment not applied
      templates = if   templatesDir != null
                  then mapAttrsRecursive (path: value:
                         import value
                       ) (fetchTemplateDir templatesDir)
                  else null;
      # theme static files
      files = if   filesDir != null
              then filesDir
              else null;
    };

  /* Generate a doc attribute set
     remove replace types byt type description
     and non mkOptoin to a mkOption with a default
  */
  mkDoc = {
    decls
  # function to trasform options, by default we turn type into it description
  , optionFn ? (o: o // (if o ? type then { type = o.type.description; } else {}))
  # function to trasform single values
  , valueFn  ? (v: mkOption { default = v; })
  }:
    let
      recurse = set:
        let
          g = name: value:
            if isOption value then optionFn value
            else if isAttrs value
                 then recurse value
                 else valueFn value;
        in mapAttrs g set;
      result = recurse set;
  in recurse decls;

  /* Format a doc set generated by mkDoc to a documentation proplist
  */
  docText = docSet:
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

  /* Generate theme configuration interface data
  */
  mkDocs = {
    docs
  , decls
  , optionFn
  , valueFn
  }:
    let
    f = path: set:
      map (key:
        let
          value = set.${key};
          data = {
                   description = value;
                   type        = attrByPath (path ++ [ key "type" "description" ]) null decls;
                   default     = attrByPath (path ++ [ key "default" ]) null decls;
                   example     = attrByPath (path ++ [ key "example" ]) null decls;
                   path        = path ++ [ key ];
                   pathString  = concatStringsSep "." newPath;
                 };
          newPath = path ++ [ key ];
        in
        if isAttrs value
           then f newPath value
           else data
      ) (attrNames set);
    in filter (t: t.description != null) (flatten (f [] docs));

}
