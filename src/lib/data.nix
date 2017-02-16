# Data functions

lib: pkgs:
with lib;
with (import ./utils.nix lib);
with (import ./proplist.nix lib);

let

  /* Supported content types
  */
  supportedFiles = flatten (attrValues ext);

  ext = {
    # markups
    asciidoc = [ "asciidoc" "adoc" ];
    markdown = [ "markdown" "mdown" "md" ];
    # other
    nix      = [ "nix" ];
    image    = [ "jpeg" "jpg" "png" "gif" ];
  };

  markupExts = ext.asciidoc ++ ext.markdown;

  /* Convert commands
  */
  commands = {
    asciidoc = "asciidoctor -b xhtml5 -s -a showtitle -o-";
    markdown = "multimarkdown";
  };

  /* Parse a markup file to an attribute set
     Extract what it can
  */
  parseMarkupFile = fileData:
    let
      markupType = head (attrNames (filterAttrs (k: v: elem fileData.ext v) ext));
      path = "${fileData.dir + "/${fileData.name}"}";
      data = pkgs.runCommand "parsed-data" {
        buildInputs = [ pkgs.styx ];
      } ''
        # metablock separator
        metaBlock="/^{---$/,/^---}$/p"
        # pageSeparator
        pageSep="<<<"
        # intro separator
        introSep="^>>>$"

        mkdir $out

        # initializing files
        cp ${path} $out/source
        chmod u+rw $out/source
        touch $out/intro
        touch $out/content
        echo "{}" > $out/meta
        mkdir $out/subpages

        # metadata
        if [ "$(sed -n "$metaBlock" < $out/source)" ]; then
          echo "{" > $out/meta
          sed -n "$metaBlock" < $out/source | sed '1d;$d' >> $out/meta
          echo "}" >> $out/meta
          sed -i "1,$(cat $out/meta | wc -l)d" $out/source
        fi

        # intro
        if [ "$(grep "$introSep" $out/source)" ]; then
          csplit -s -f intro $out/source "/$introSep/"
          cp intro00 $out/intro
          sed -i "/$introSep/d" $out/source
        fi

        # subpages
        if [ "$(grep -Fx "$pageSep" $out/source)" ]; then
          csplit --suppress-matched -s -f subpage $out/source  "/^$pageSep/" '{*}'
          cp subpage* $out/subpages
          sed -i "/$pageSep/d" $out/source
        fi

        # Converting markup files
        ${commands."${markupType}"} $out/source > $out/content

        # intro
        cp $out/intro tmp; ${commands."${markupType}"} tmp | tr -d '\n' > $out/intro

        # subpages
        for file in $out/subpages/*; do
          cp $file tmp; ${commands."${markupType}"} tmp > $file
        done
      '';
      content = let
          rawContent = readFile "${data}/content";
        in if rawContent == "" then {} else { content = rawContent; } ;
      intro = let
          rawContent = readFile "${data}/intro";
        in if rawContent == "" then {} else { intro = rawContent; };
      pages = let
          dir = "${data}/subpages";
          subpages = mapAttrsToList (k: v:
            { content = readFile "${dir}/${k}"; }
          ) (readDir dir);
        in if subpages != []
              then { pages = subpages; }
              else { };

      meta = import "${data}/meta";
    in
      content // intro // meta // pages;

  /* Get data from a file
  */
  parseFile = fileData:
    let
      m    = match "^([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}:[0-9]{2})?)?\-?(.*)$" fileData.basename;
      date = if m != null && (elemAt m 0)  != null then { date = (elemAt m 0); } else {};
      path = "${fileData.dir + "/${fileData.name}"}";
      data =      if elem fileData.ext markupExts then parseMarkupFile fileData
             else if elem fileData.ext ext.nix    then import path
             else    abort "Error: this should never happen.";
    in
      { inherit fileData; } // date // data;

  /* Get a list of files data from a directory
     Ignore unsupported files type

     Return example

       [ { basename = "file"; ext = "nix"; name = "file.nix"; dir = "/foo/bar"; } ]
  */
  getFiles = from:
    let
      fileList = mapAttrsToList (k: v:
        let 
          m = match "^(.*)\\.([^.]+)$" k;
          basename = elemAt m 0;
          ext = elemAt m 1;
        in
        if (v == "regular") && (m != null) && (elem ext supportedFiles)
           then { inherit basename ext; dir = from; name = k; }
           else trace "Warning: File '${k}' is not in a supported file format and will be ignored." null
      ) (readDir from);
    in filter (x: x != null) fileList;

  markupToHtml = markup: text:
    let
      data = pkgs.runCommand "markup-data" { buildInputs = [ pkgs.styx ]; } ''
        mkdir $out
        echo -n '${replaceStrings ["'"] ["'\i'''"] text}' > $out/source
        ${commands."${markup}"} $out/source > $out/content
      '';
    in readFile "${data}/content";

in
rec {

  _documentation = _: ''
    The data namespace contains functions to fetch and manipulate data.
  '';

# -----------------------------

  loadDir = documentedFunction {
    description = ''
      Load a directory containing data that styx can handle.
    '';

    arguments = {
      dir = {
        description = "The directory to load data from.";
        type = "Path";
      };
      substitutions = {
        description = "A substitution set to apply to the loaded data.";
        type = "Attrs";
        default = {};
      };
      filterDraftsFn = {
        description = "Function to filter the drafts.";
        type = "Draft -> Bool";
        default = literalExample "d: !((! renderDrafts) && (attrByPath [\"draft\"] false d))";
      };
      renderDrafts = {
        description = "Whether or not to render the drafts.";
        type = "Bool";
        default = false;
      };
      asAttrs = {
        description = "If set to true, the function will return a set instead of a list. The key will be the file basename, and the value the data set.";
        type = "Bool";
        default = false;
      };
    };

    return = "A list of data attribute sets. (Or a set of data set if `asAttrs` is `true`)";

    examples = [ (mkExample {
      literalCode = ''
        data.posts = loadDir {
          dir = ./data/posts;
        });
      '';
    }) ];

    notes = ''
      Any extra attribute in the argument set will be added to every loaded data attribute set.
    '';

    function = {
      dir
    , substitutions  ? {}
    , filterDraftsFn ? (d: !((! renderDrafts) && (attrByPath ["draft"] false d)))
    , renderDrafts   ? false
    , asAttrs        ? false
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "dir" "substitutions" "filterDraftsFn" "renderDrafts" "asAttrs" ];
        data = map (fileData:
          (parseFile fileData) // extraArgs
        ) (getFiles dir);
        list  = filter filterDraftsFn data;
        attrs = fold (d: acc: acc // { "${d.fileData.basename}" = d; }) {} list;
    in
      if asAttrs then attrs else list;
      #filter filterDraftsFn data;
  };

# -----------------------------

  loadFile = documentedFunction {
    description = ''
      Load a directory containing data that styx can handle.
    '';

    arguments = {
      dir = {
        description = "The directory where the file is located.";
        type = "Path";
      };
      file = {
        description = "The file to load.";
        type = "String";
      };
      substitutions = {
        description = "A substitution set to apply to the loaded file.";
        type = "Attrs";
        default = {};
      };
    };

    return = "A data attribute set.";

    examples = [ (mkExample {
      literalCode = ''
        data.about = loadFile {
          dir  = ./data/pages;
          file = "about.md";
        });
      '';
    }) ];

    function = {
      dir
    , file
    , substitutions ? {}
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "dir" "file" "substitutions" ];
        m = match "^(.*)\\.([^.]+)$" file;
        basename = elemAt m 0;
        ext = elemAt m 1;
        fileData = { inherit dir basename ext; name = file; };
      in
        (parseFile fileData) // extraArgs;
  };

# -----------------------------

  markdownToHtml = documentedFunction {
    description = "Convert markdown text to HTML.";

    arguments = [
      {
        name = "text";
        description = "Text in markdown format";
        type = "String";
      }
    ];

    return = "`String`";

    examples = [ (mkExample {
      literalCode = ''
        markdownToHtml "Hello `markdown`!"
      '';
      code = 
        markdownToHtml "Hello `markdown`!"
      ;
    }) ];
    
    function = markupToHtml "markdown";
  };

# -----------------------------

  asciidocToHtml = documentedFunction {
    description = "Convert asciidoc text to HTML.";

    arguments = [
      {
        name = "text";
        description = "Text in asciidoc format.";
        type = "String";
      }
    ];

    examples = [ (mkExample {
      literalCode = ''
        asciidocToHtml "Hello `asciidoc`!"
      '';
      code = 
        asciidocToHtml "Hello `asciidoc`!"
      ;
    }) ];

    return = "`String`";
    
    function = markupToHtml "asciidoc";
  };

# -----------------------------

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

# -----------------------------

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

# -----------------------------

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

# -----------------------------

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
