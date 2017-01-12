# themes

lib:
with lib;
with import ./utils.nix lib;

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

  /* import a file and if it is a function load apply args to it
  */
  importApply = file: arg:
    let f = import file;
    in if isFunction f then f arg else f;
in
rec {

  /* Load themes related files

     returns an attribute set containing:
       - conf: the loaded configuration set
       - lib: the loaded lib
       - files: the loaded static files paths
       - templates: the loaded templates attribute set
       - themes: the list of loaded themes information

     This is mainly a wrapper to the other lib.themes.load* functions
  */
  load = {
  # styx library
    styxLib
  # list of themes as path or packages
  , themes ? []
  # configuration loading arguments
  , conf ? {}
  # library loading arguments
  , lib ? {}
  # files loading arguments
  , files ? {}
  # templates loading arguments
  , templates ? {}
  }:
  let
    themes' = loadThemes { inherit themes; metaFnArg = { lib = lib'; }; };

    conf' = 
      let themesConf = loadConf ({
        themes = themes';
        confFnArg = { lib = styxLib; };
      } // (removeAttrs conf [ "extra" ]));
    in styxLib.utils.merge ([ themesConf ] ++ (conf.extra or []));

    lib' = 
      let themesLib = loadLib ({
        themes = themes';
        libFnArg = { lib = styxLib; };
      } // lib);
    in recursiveUpdate styxLib themesLib;

    files' = loadFiles ({
      themes = themes';
    } // files);

    templates' =
      let templatesArgs = {
          themes = themes';
        } 
        // removeAttrs templates [ "extraEnv" ]
        // { environment = (templates.extraEnv or {})
             // { conf = conf'; lib = lib'; templates = templates'; }; };
    in loadTemplates templatesArgs;
  in
  {
    conf      = conf';
    lib       = lib';
    files     = files';
    templates = templates';
    themes    = themes';
  };
  
  /* convert a list of themes into a list of sets with name, meta and path attributes

       [ { name = "foo"; meta = { ... }; path = "/nix/store/..."; } ]
  */
  loadThemes = {
    themes
  , metaFnArg ? { inherit lib; }
  }:
    map (theme:
      rec { meta = importApply (theme + "/meta.nix") metaFnArg; name = meta.name; path = theme; }
    ) themes;

  /* Load the configuration files from 'themes' list of themes
     This load the themes configuration in a set, splitting in two keys

      - theme: set containing all the themes conf merged
      - themes.NAME: the theme configuration as it is declared

     For example a foo theme configuration:

       {
         themes = {
           bar = "hello";
           baz = 5; };
       }

     Will be converted to:

       {
         theme = {
           bar = "hello";
           baz = 5; };

         themes.foo = {
           bar = "hello";
           baz = 5; };
       }
  */
  loadConf = {
    themes
  , confFnArg ? {}
  }:
  let
    confs = filter (t: t.file != null) (map (t: t // { file = findInTheme t "conf.nix"; }) themes);
  in
  fold (theme: acc:
    let
      conf      =  importApply theme.file confFnArg;
      themeSet  = {
        themes."${theme.name}" = conf;
        theme = conf;
      };
    in recursiveUpdate themeSet acc
  ) {} confs;


  /* Load themes static files from 'themes' list of themes
  */
  loadFiles = {
    themes
  }:
    filter (p: p != null)
      (map (t: findInTheme t "files") themes);

  /* Loads the templates from 'themes' list of themes
  */
  loadTemplates = {
    themes
  , environment
  , customEnvironments ? {}
  }:
  let
    templates = filter (p: p != null) (map (t: findInTheme t "templates") themes);
  in
  fold (dir: acc:
    let
      templateSet  = fetchTemplateDir dir;
      templatesWithEnv = mapAttrsRecursive (path: value:
        let 
          env = if hasAttrByPath path customEnvironments
                   then environment // (getAttrFromPath path customEnvironments)
                   else environment;
          in if hasAttrByPath path acc
                then null
                else import value env
      ) templateSet;
    in recursiveUpdate templatesWithEnv acc
  ) {} templates;

  /* Load the libraries from 'themes' list of themes
  */
  loadLib = {
    themes
  , libFnArg ? {}
  }:
  let
    libs = filter (p: p != null) (map (t: findInTheme t "lib.nix") themes);
  in fold (file: acc:
    recursiveUpdate (importApply file libFnArg) acc
  ) {} libs;

}
