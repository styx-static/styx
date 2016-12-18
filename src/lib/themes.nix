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
  loadConf = themes:
  fold (theme: set:
    let
      themeConf = import "${theme}/theme.nix";
      themeSet  = if hasAttrByPath ["meta" "name"] themeConf
        then {
          themes."${themeConf.meta.name}" = themeConf;
          theme = removeAttrs themeConf ["meta"];
        }
        else abort "'${theme}' theme's theme.nix file does not declare a `meta.name` attribute.";
    in recursiveUpdate set themeSet
  ) {} themes;


  /* Load template files from 'themes' list of themes
  */
  loadFiles = themes:
    map (theme:
      "${theme}/files"
    ) (reverseList themes);

  /* Loads the templates from 'themes' list of themes
  */
  loadTemplates = {
    themes
  , environment
  , customEnvironments ? {}
  }:
  fold (theme: set:
    let
      templatesDir = "${theme}/templates";
      templateSet  = fetchTemplateDir templatesDir;
      templatesWithEnv = mapAttrsRecursive (path: value:
        let 
          env = if hasAttrByPath path customEnvironments
                   then getAttrFromPath path customEnvironments
                   else environment;
          in if hasAttrByPath path set
                then null
                else import value env
      ) templateSet;
    in recursiveUpdate templatesWithEnv set
  ) {} (reverseList themes);

}
