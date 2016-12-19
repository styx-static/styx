# themes

lib:
with lib;

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
             else if nixFile != null then nameValuePair (elemAt nixFile 0) ("${dir}/${k}")
             # non-nix files
             else nameValuePair k null
        )
        (readDir dir);
      # removing any non-nix files
      cleanup = filterAttrsRecursive (n: v: v != null);
    in
      cleanup (f [ dir ] dir);
in
{

  /* Load the configuration files from 'themes' lit of themes
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
  , getConfFn ? (theme: theme + "/theme.nix")
  , confFnArg ? {}
  }:
  fold (theme: acc:
    let
      conf      = import (getConfFn theme);
      themeConf = if isFunction conf then conf confFnArg else conf;
      themeSet  = if hasAttrByPath ["meta" "name"] themeConf
        then {
          themes."${themeConf.meta.name}" = themeConf;
          theme = removeAttrs themeConf ["meta"];
        }
        else abort "'${theme}' theme configuration file must declare a `meta.name` attribute.";
    in recursiveUpdate themeSet acc
  ) {} (reverseList themes);


  /* Load template files from 'themes' list of themes
  */
  loadFiles = {
    themes
  , getFilesFn ? (theme: theme + "/files")
  }:
    map getFilesFn (reverseList themes);

  /* Loads the templates from 'themes' list of themes
  */
  loadTemplates = {
    themes
  , environment
  , customEnvironments ? {}
  , getTemplatesFn ? (theme: theme + "/templates")
  }:
  fold (theme: acc:
    let
      templatesDir = getTemplatesFn theme;
      templateSet  = fetchTemplateDir templatesDir;
      templatesWithEnv = mapAttrsRecursive (path: value:
        let 
          env = if hasAttrByPath path customEnvironments
                   then getAttrFromPath path customEnvironments
                   else environment;
          in if hasAttrByPath path acc
                then null
                else import value env
      ) templateSet;
    in recursiveUpdate templatesWithEnv acc
  ) {} (reverseList themes);

  /* Load the libraries from 'themes' list of themes
  */
  loadLib = {
    themes
  , getLibFn ? (theme: theme + "/lib/default.nix")
  , libFnArg ? {}
  }:
  fold (theme: acc:
    let
      libFile   = getLibFn theme;
      themeLib' = if pathExists libFile then import libFile else {};
      themeLib  = if isFunction themeLib' then themeLib' libFnArg else themeLib';
    in recursiveUpdate themeLib acc
  ) {} (reverseList themes);

}
