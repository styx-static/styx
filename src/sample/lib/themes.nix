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

  /* Load template files from 'themes' list of themes
  */
  loadFiles = {
    themes
  , themesDir
  }:
  map (theme:
    (themesDir + "/${theme}/files")
  ) themes;

  /* Loads the templates from 'themes' list of themes
  */
  loadTemplates = {
    themes
  , themesDir
  , defaultEnvironment
  , customEnvironments ? {}
  }:
  fold (theme: set:
    let
      templatesDir = themesDir + "/${theme}/templates";
      templateSet = fetchTemplateDir templatesDir;
      templatesWithEnv = mapAttrsRecursive (path: value:
        let 
          env = if hasAttrByPath path customEnvironments
                   then getAttrFromPath path customEnvironments
                   else defaultEnvironment;
          in import value env
      ) templateSet;
    in recursiveUpdate set templatesWithEnv
  ) {} themes;

}
