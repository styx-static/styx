{
  l,
  nixpkgs,
  styxlib,
}:
lib.fix' (self: let
  inherit (styxlib) utils;

  evaledMarkup = self.config.styx.markup;

  evaledMarkupFiles = l.mapAttrs (n: v: v.extensions) evaledMarkup;
  evaledMarkupExts = l.flatten (l.attrValues evaledMarkupFiles);

  supportedFiles =
    {
      "nix" = ["nix"];
    }
    // evaledMarkupFiles;
  supportedExts = l.flatten (l.attrValues supportedFiles);

  /*
  parse markup file to a nix file
  */
  parseMarkupFile = {
    fileData,
    env,
  }: let
    markupType = l.head (l.attrNames (l.filterAttrs (k: v: elem fileData.ext v) evaledMarkupFiles));
    markupAttrs = ["intro" "pages" "content"];
    dataFn =
      nixpkgs.runCommand "parsed-data.nix" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      }
      (evaledMarkup."${markupType}".parser fileData.path);
    data = utils.importApply dataFn env;
  in
    l.mapAttrs (
      k: v:
        if l.elem k markupAttrs
        then
          if k == "pages"
          then
            map (c: {
              content = markupToHtml markupType c;
              inherit fileData;
            })
            v
          else markupToHtml markupType v
        else v
    )
    data;

  /*
  parse a file with the right parser
  */
  parseFile = {
    fileData,
    env,
  }: let
    m = l.match "^([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}:[0-9]{2})?)?\-?(.*)$" fileData.basename;
    date =
      if m != null && (l.elemAt m 0) != null
      then {date = l.elemAt m 0;}
      else {};
    data =
      if l.elem fileData.ext evaledMarkupExts
      then parseMarkupFile {inherit fileData env;}
      else if fileData.ext == "nix"
      then utils.importApply fileData.path env
      else l.trace "Warning: File '${fileData.path}' is not in a supported file format and will be ignored." {};
  in
    {inherit fileData;} // date // data;

  /*
  Convert markup code to HTML
  */
  markupToHtml = markupType: text: let
    data =
      nixpkgs.runCommand "markup-data.html" {
        preferLocalBuild = true;
        allowSubstitutes = false;
        inherit text;
        passAsFile = ["text"];
      }
      (evaledMarkup."${markupType}".converter "$textPath");
  in
    l.readFile data;

  /*
  extract a file data
  */
  getFileData = path: let
    m = l.match "^(.*/)([^/]*)\\.([^.]+)$" (toString path);
    dir = l.elemAt m 0;
    basename = l.elemAt m 1;
    ext = l.elemAt m 2;
  in {
    inherit dir basename ext path;
    name = "${basename}.${ext}";
  };

  /*
  get files from a directory
  */
  getFiles = dir: let
    fileList = l.mapAttrsToList (
      k: v: let
        m = l.match "^(.*)\\.([^.]+)$" k;
        basename = l.elemAt m 0;
        ext = l.elemAt m 1;
        path = "${dir}/${k}";
      in
        if (v == "regular") && (m != null) && (l.elem ext supportedExts)
        then getFileData path
        else l.trace "Warning: File '${path}' is not in a supported file format and will be ignored." null
    ) (l.readDir dir);
  in
    l.filter (x: x != null) fileList;
in {
  __functor = self: {config}: l.fix' (l.extends (_: _: {inherit config;} self.__unfix__));
  config = throw ''
    This styxlib.data instance is not initialized with the evaluated styx config.

    Initialize regularily with styxlib.themes.load function.
    Initialize irregularily with styxlib.data { config = evaledStyxConfig; };
  '';
  _documentation = _: ''
    The data namespace contains functions to fetch and manipulate data.
  '';

  /*
  ===============================================================

   loadDir

  ===============================================================
  */

  loadDir = utils.documentedFunction {
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
        default = l.literalExpression ''d: !( ( !(attrByPath ["conf" "renderDrafts"] false env) ) && (attrByPath ["draft"] false d) )'';
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          data.posts = styxlib.data.loadDir {
            dir = ./data/posts;
            inherit env;
          };
        '';
      })
    ];

    notes = ''
      Any extra attribute in the argument set will be added to every loaded data attribute set.
    '';

    function = {
      dir,
      filterDraftsFn ? (d: !((! (l.attrByPath ["conf" "renderDrafts"] false env)) && (l.attrByPath ["draft"] false d))),
      asAttrs ? false,
      env ? {},
      ...
    } @ args: let
      extraArgs = l.removeAttrs args ["dir" "filterDraftsFn" "asAttrs" "env"];
      data = map (
        fileData:
          (parseFile {inherit fileData env;}) // extraArgs
      ) (getFiles dir);
      list = l.filter filterDraftsFn data;
      attrs = l.fold (d: acc: acc // {"${d.fileData.basename}" = d;}) {} list;
    in
      if asAttrs
      then attrs
      else list;
  };

  /*
  ===============================================================

   loadFile

  ===============================================================
  */

  loadFile = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          data.posts = data.loadFile {
            file = ./data/pages/about.md;
            inherit env;
          };
        '';
      })
    ];

    notes = ''
      Any extra attribute in the argument set will be added to the data attribute set.
    '';

    function = {
      env ? {},
      file,
      ...
    } @ args: let
      extraArgs = l.removeAttrs args ["file" "env"];
    in
      (parseFile {
        fileData = getFileData file;
        inherit env;
      })
      // extraArgs;
  };

  /*
  ===============================================================

   markdownToHtml

  ===============================================================
  */

  markdownToHtml = utils.documentedFunction {
    description = "Convert markdown text to HTML.";

    arguments = [
      {
        name = "text";
        description = "Text in markdown format";
        type = "String";
      }
    ];

    return = "`String`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.data.markdownToHtml "Hello `markdown`!"
        '';
        code =
          styxlib.data.markdownToHtml "Hello `markdown`!";
        expected = ''
          <p>Hello <code>markdown</code>!</p>
        '';
      })
    ];

    function = styxlib.data.markupToHtml "markdown";
  };

  /*
  ===============================================================

   asciidocToHtml

  ===============================================================
  */

  asciidocToHtml = utils.documentedFunction {
    description = "Convert asciidoc text to HTML.";

    arguments = [
      {
        name = "text";
        description = "Text in asciidoc format.";
        type = "String";
      }
    ];

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.data.asciidocToHtml "Hello `asciidoc`!"
        '';
        code =
          styxlib.data.asciidocToHtml "Hello `asciidoc`!";
        expected = ''
          <div class="paragraph">
          <p>Hello <code>asciidoc</code>!</p>
          </div>
        '';
      })
    ];

    return = "`String`";

    function = styxlib.data.markupToHtml "asciidoc";
  };

  /*
  ===============================================================

   mkTaxonomyData

  ===============================================================
  */

  mkTaxonomyData = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
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
        code = mkTaxonomyData {
          data = [
            {
              tags = ["foo" "bar"];
              path = "/a.html";
            }
            {
              tags = ["foo"];
              path = "/b.html";
            }
            {
              category = ["baz"];
              path = "/c.html";
            }
          ];
          taxonomies = ["tags" "category"];
        };
        expected = [
          {
            category = [
              {
                baz = [
                  {
                    category = ["baz"];
                    path = "/c.html";
                  }
                ];
              }
            ];
          }
          {
            tags = [
              {
                foo = [
                  {
                    path = "/b.html";
                    tags = ["foo"];
                  }
                  {
                    path = "/a.html";
                    tags = ["foo" "bar"];
                  }
                ];
              }
              {
                bar = [
                  {
                    path = "/a.html";
                    tags = ["foo" "bar"];
                  }
                ];
              }
            ];
          }
        ];
      })
    ];

    function = {
      data,
      taxonomies,
    }: let
      rawTaxonomy =
        fold (
          taxonomy: plist:
            fold (
              set: plist:
                fold (
                  term: plist:
                    plist ++ [{"${taxonomy}" = [{"${term}" = [set];}];}]
                )
                plist
                set."${taxonomy}"
            )
            plist (filter (d: hasAttr taxonomy d) data)
        ) []
        taxonomies;
      semiCleanTaxonomy = propFlatten rawTaxonomy;
      cleanTaxonomy =
        map (
          pl: {"${propKey pl}" = propFlatten (propValue pl);}
        )
        semiCleanTaxonomy;
    in
      cleanTaxonomy;
  };

  /*
  ===============================================================

   sortTerms

  ===============================================================
  */

  sortTerms = utils.documentedFunction {
    description = "Sort taxonomy terms by number of occurences.";

    arguments = [
      {
        name = "terms";
        description = "List of taxonomy terms attribute sets.";
        type = "[ Terms ]";
      }
    ];

    return = "Sorted list of taxonomy terms attribute sets.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          sortTerms [ { bar = [ {} {} ]; } { foo = [ {} {} {} ]; } ]
        '';
        code =
          sortTerms [{bar = [{} {}];} {foo = [{} {} {}];}];
        expected = [
          {foo = [{} {} {}];}
          {bar = [{} {}];}
        ];
      })
    ];

    function = sort (a: b: valuesNb a > valuesNb b);
  };

  /*
  ===============================================================

   valuesNb

  ===============================================================
  */

  valuesNb = utils.documentedFunction {
    description = "Calculate the number of values in a taxonomy term attribute set.";

    arguments = [
      {
        name = "term";
        description = "Taxonomy terms attribute set.";
        type = "Terms";
      }
    ];

    return = "`Int`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          valuesNb { foo = [ {} {} {} ]; }
        '';
        code =
          valuesNb {foo = [{} {} {}];};
        expected = 3;
      })
    ];

    function = term: length (propValue term);
  };

  /*
  ===============================================================

   groupBy

  ===============================================================
  */

  groupBy = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
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
            {
              type = "fruit";
              name = "apple";
            }
            {
              type = "fruit";
              name = "pear";
            }
            {
              type = "vegetable";
              name = "lettuce";
            }
          ]
          (s: s.type);
        expected = [
          {
            fruit = [
              {
                type = "fruit";
                name = "apple";
              }
              {
                type = "fruit";
                name = "pear";
              }
            ];
          }
          {
            vegetable = [
              {
                type = "vegetable";
                name = "lettuce";
              }
            ];
          }
        ];
      })
    ];

    function = list: f: propFlatten (map (d: {"${f d}" = [d];}) list);
  };
})
