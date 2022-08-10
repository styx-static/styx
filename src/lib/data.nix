# Data functions

{ pkgs, conf, lib }@args:
with lib;
with (import ./utils.nix args);
with (import ./proplist.nix args);

let

  markupFiles = mapAttrs (n: v: v.extensions) conf.lib.data.markup;
  markupExts  = flatten (attrValues markupFiles);

  supportedFiles = {
    "nix" = ["nix"];
  } // markupFiles;
  supportedExts  = flatten (attrValues supportedFiles);


  /* parse markup file to a nix file
  */
  parseMarkupFile = {
    fileData
  , env
  }:
    let
      markupType = head (attrNames (filterAttrs (k: v: elem fileData.ext v) markupFiles));
      markupAttrs = [ "intro" "pages" "content" ];
      dataFn = pkgs.runCommand "parsed-data.nix" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } 
      (conf.lib.data.markup."${markup}".parser fileData.path);
      data = importApply dataFn env;
    in mapAttrs (k: v:
      if   elem k markupAttrs
      then if   k == "pages"
           then map (c: { content = markupToHtml markupType c; inherit fileData; }) v
           else markupToHtml markupType v
      else v
    ) data;


  /* parse a file with the right parser
  */
  parseFile = {
    fileData
  , env }:
    let
      m    = match "^([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}:[0-9]{2})?)?\-?(.*)$" fileData.basename;
      date = if m != null && (elemAt m 0)  != null then { date = (elemAt m 0); } else {};
      data =      if elem fileData.ext markupExts then parseMarkupFile { inherit fileData env; }
             else if fileData.ext == "nix"        then importApply fileData.path env
             else trace "Warning: File '${fileData.path}' is not in a supported file format and will be ignored." {};
    in
      { inherit fileData; } // date // data;

  /* Convert markup code to HTML
  */
  markupToHtml = markup: text:
    let
      data = pkgs.runCommand "markup-data.html" {
        preferLocalBuild = true;
        allowSubstitutes = false;
        inherit text;
        passAsFile = [ "text" ];
      } 
      (conf.lib.data.markup."${markup}".converter "$textPath");
    in readFile data;

  /* extract a file data
  */
  getFileData = path:
    let
      m = match "^(.*/)([^/]*)\\.([^.]+)$" (toString path);
      dir = elemAt m 0;
      basename = elemAt m 1;
      ext = elemAt m 2;
    in { inherit dir basename ext path; name = "${basename}.${ext}"; };

  /* get files from a directory
  */
  getFiles = dir:
    let
      fileList = mapAttrsToList (k: v:
        let
          m = match "^(.*)\\.([^.]+)$" k;
          basename = elemAt m 0;
          ext = elemAt m 1;
          path = "${dir}/${k}";
        in
        if (v == "regular") && (m != null) && (elem ext supportedExts)
           then getFileData path
           else trace "Warning: File '${path}' is not in a supported file format and will be ignored." null
      ) (readDir dir);
    in filter (x: x != null) fileList;


in
rec {

  _documentation = _: ''
    The data namespace contains functions to fetch and manipulate data.
  '';


/*
===============================================================

 loadDir

===============================================================
*/

  loadDir = documentedFunction {
    description = ''
      Load a directory containing data that styx can handle.
    '';

    arguments = {
      dir = {
        description = "The directory to load data from.";
        type = "Path";
      };
      filterDraftsFn = {
        description = "Function to filter the drafts.";
        type = "Draft -> Bool";
        default = literalExample ''d: !( ( !(attrByPath ["conf" "renderDrafts"] false env) ) && (attrByPath ["draft"] false d) )'';
      };
      asAttrs = {
        description = "If set to true, the function will return a set instead of a list. The key will be the file basename, and the value the data set.";
        type = "Bool";
        default = false;
      };
      env = {
        description = "The nix environment to use in loaded files.";
        type = "Attrs";
        default = {};
      };
    };

    return = "A list of data attribute sets. (Or a set of data set if `asAttrs` is `true`)";

    examples = [ (mkExample {
      literalCode = ''
        data.posts = loadDir {
          dir = ./data/posts;
          inherit env;
        };
      '';
    }) ];

    notes = ''
      Any extra attribute in the argument set will be added to every loaded data attribute set.
    '';

    function = {
      dir
    , filterDraftsFn ? (d: !((! (attrByPath ["conf" "renderDrafts"] false env) ) && (attrByPath ["draft"] false d)))
    , asAttrs        ? false
    , env            ? {}
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "dir" "filterDraftsFn" "asAttrs" "env" ];
        data = map (fileData:
          (parseFile { inherit fileData env; }) // extraArgs
        ) (getFiles dir);
        list  = filter filterDraftsFn data;
        attrs = fold (d: acc: acc // { "${d.fileData.basename}" = d; }) {} list;
    in
      if asAttrs then attrs else list;
  };



/*
===============================================================

 loadFile

===============================================================
*/

  loadFile = documentedFunction {
    description = "Loads a data file";

    arguments = {
      file = {
        description = "Path of the file to load.";
        type = "Path";
      };
      env = {
        description = "The nix environment to use in loaded file.";
        type = "Attrs";
        default = {};
      };
    };

    return = "A list of data attribute sets. (Or a set of data set if `asAttrs` is `true`)";

    examples = [ (mkExample {
      literalCode = ''
        data.posts = loadFile {
          file = ./data/pages/about.md;
          inherit env;
        };
      '';
    }) ];

    notes = ''
      Any extra attribute in the argument set will be added to the data attribute set.
    '';

    function = {
      env ? {}
    , file
    , ... }@args:
    let
      extraArgs = removeAttrs args [ "file" "env" ];
    in (parseFile { fileData = getFileData file; inherit env; }) // extraArgs;
  };



/*
===============================================================

 mkTaxonomyData

===============================================================
*/

  mkTaxonomyData = documentedFunction {
    description = ''
      Generate taxonomy data from a list of data attribute sets.
    '';

    arguments = {
      data = {
        description = "A list of data attribute sets to extract taxonomy data from.";
        type = "[ Data ]";
      };
      Taxonomies = {
        description = "A list of taxonomies to extract.";
        type = "[ String ]";
      };
    };

    return = "A taxonomy attribute set.";

    examples = [ (mkExample {
      literalCode = ''
        mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; }
            { tags = [ "foo" ];       path = "/b.html"; }
            { category = [ "baz" ];   path = "/c.html"; }
          ];
          taxonomies = [ "tags" "category" ];
        }
      '';
      code =
        mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; }
            { tags = [ "foo" ];       path = "/b.html"; }
            { category = [ "baz" ];   path = "/c.html"; }
          ];
          taxonomies = [ "tags" "category" ];
        }
      ;
      expected = [ {
        category = [ {
          baz = [ { category = [ "baz" ]; path = "/c.html"; } ];
        } ];
      } {
        tags = [ {
          foo = [
            { path = "/b.html"; tags = [ "foo" ]; }
            { path = "/a.html"; tags = [ "foo" "bar" ]; }
          ];
        } {
          bar = [ {path = "/a.html"; tags = [ "foo" "bar" ]; } ];
        } ];
      } ];
    }) ];

    function = { data, taxonomies }:
      let
        rawTaxonomy =
          fold (taxonomy: plist:
            fold (set: plist:
              fold (term: plist:
                plist ++ [ { "${taxonomy}" = [ { "${term}" = [ set ]; } ]; } ]
              ) plist set."${taxonomy}"
            ) plist (filter (d: hasAttr taxonomy d) data)
          ) [] taxonomies;
        semiCleanTaxonomy = propFlatten rawTaxonomy;
        cleanTaxonomy = map (pl:
          { "${propKey pl}" = propFlatten (propValue pl); }
        ) semiCleanTaxonomy;
      in cleanTaxonomy;
  };



/*
===============================================================

 sortTerms

===============================================================
*/

  sortTerms = documentedFunction {
    description = "Sort taxonomy terms by number of occurences.";

    arguments = [
      {
        name = "terms";
        description = "List of taxonomy terms attribute sets.";
        type = "[ Terms ]";
      }
    ];

    return = "Sorted list of taxonomy terms attribute sets.";

    examples = [ (mkExample {
      literalCode = ''
        sortTerms [ { bar = [ {} {} ]; } { foo = [ {} {} {} ]; } ]
      '';
      code =
        sortTerms [ { bar = [ {} {} ]; } { foo = [ {} {} {} ]; } ]
      ;
      expected = [
        { foo = [ {} {} {} ]; } { bar = [ {} {} ]; }
      ];
    }) ];

    function = sort (a: b: valuesNb a > valuesNb b);
  };



/*
===============================================================

 valuesNb

===============================================================
*/

  valuesNb = documentedFunction {
    description = "Calculate the number of values in a taxonomy term attribute set.";

    arguments = [
      {
        name = "term";
        description = "Taxonomy terms attribute set.";
        type = "Terms";
      }
    ];

    return = "`Int`";

    examples = [ (mkExample {
      literalCode = ''
        valuesNb { foo = [ {} {} {} ]; }
      '';
      code =
        valuesNb { foo = [ {} {} {} ]; }
      ;
      expected = 3;
    }) ];

    function = term: length (propValue term);
  };


/*
===============================================================

 groupBy

===============================================================
*/

  groupBy = documentedFunction {

    description = "Group a list of attribute sets.";

    arguments = [
      {
        name = "list";
        description = "List of attribute sets.";
        type = "[ Attrs ]";
      }
      {
        name = "f";
        description = "Function to generate the group name.";
        type = "Attrs -> String";
      }
    ];

    return = "A property list of grouped attribute sets";

    examples = [ (mkExample {
      literalCode = ''
        groupBy [
          { type = "fruit"; name = "apple"; }
          { type = "fruit"; name = "pear"; }
          { type = "vegetable"; name = "lettuce"; }
        ]
        (s: s.type)
      '';
      code =
        groupBy [
          { type = "fruit"; name = "apple"; }
          { type = "fruit"; name = "pear"; }
          { type = "vegetable"; name = "lettuce"; }
        ]
        (s: s.type)
      ;
      expected = [
        { fruit = [ { type = "fruit"; name = "apple"; } { type = "fruit"; name = "pear"; } ]; }
        { vegetable = [ { type = "vegetable"; name = "lettuce"; } ]; }
      ];
    }) ];

    function = list: f: propFlatten (map (d: { "${f d}" = [ d ]; } ) list);
  };

}
