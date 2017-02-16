# Page functions

lib:
with lib;
with import ./utils.nix lib;
with import ./proplist.nix lib;

rec {

  mkSplitCustom = documentedFunction {
    description = "Create a list of pages from a list of data.";

    arguments = {
      head = {
        description = ''
          Arguments to merge with the first splitted page.

          * Must define `itemsNb`, the number of data items to pass to the first page.
          * Must define `path`, the `path` of the page.
        '';
        type = "Attrs";
      };
      tail = {
        description = ''
          Arguments to merge with the rest of splitted page.

          * Must define `itemsNb`, the number of data items to pass to each page.
          * Should define a `basePath` that will be used to generate the pages path.
          * Can define a `pathFn` (`Attrs -> Int -> String`) function to generate the `path` of the pages, defaults to `tail: i: "''${tail.basePath}-''${toString i}.html"`.
        '';
        type = "Attrs";
      };
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
    };

    return = ''
      List of pages. Each page has:

      * `items`: List of the page data items.
      * `itemsNb`: Number of data items of the page.
      * `pages`: List of splitted pages.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.archives = mkSplitCustom {
          head = {
            itemsNb  = 3;
            template = templates.archives.head;
            path     = "/archives/index.html";
          };
          tail = {
            itemsNb  = 5;
            template = templates.archives.rest;
            basePath = "/archives/page";
          };
          data = pages.posts;
        };
      '';
    }) (mkExample {
      literalCode = ''
        mkSplitCustom {
          head = {
            itemsNb = 1;
            path    = "/archives/index.html";
          };
          tail = {
            itemsNb  = 2;
            basePath = "/archives/page";
          };
          data = range 1 4;
        }
      '';
      code = 
        mkSplitCustom {
          head = {
            itemsNb = 1;
            path    = "/archives/index.html";
          };
          tail = {
            itemsNb  = 2;
            basePath = "/archives/page";
          };
          data = range 1 4;
        }
      ;
    }) ];

    function = { 
      head
    , tail
    , data
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "head" "tail" "data" ];
        itemsList = [ (take head.itemsNb data) ] ++ (chunksOf tail.itemsNb (drop head.itemsNb data));
        pathFn = tail.pathFn or (tail: i: "${tail.basePath}-${toString i}.html");
        pages = imap (i: items:
          { inherit items; index = i; }
          // extraArgs
          // (if   i ==1
              then head
              else (removeAttrs tail [ "basePath" "pathFn" ]) // { path = pathFn tail i; })
        ) itemsList;
      in map (p: p // { inherit pages; }) pages;
  };

# -----------------------------

  mkSplit = documentedFunction {
    description = "Create a list of pages from a list of data. A simpler version of `mkSplitCustom` that should fit most needs.";

    arguments = {
      basePath = {
        description = ''
          Arguments to merge with the first splitted page.

          * Must define `itemsNb`, the number of data items to pass to the first page.
        '';
        type = "Attrs";
      };
      tail = {
        description = ''
          Arguments to merge with the rest of splitted page.

          * Must define `itemsNb`, the number of data items to pass to each page.
        '';
        type = "Attrs";
      };
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
    };

    return = ''
      List of pages. Each page has:

      * `items`: List of the page data items.
      * `itemsNb`: Number of data items of the page.
      * `pages`: List of splitted pages.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.archives = mkSplit {
          basePath     = "archives";
          itemsPerPage = 10;
          data         = pages.posts;
          template     = templates.archives;
        };
      '';
    }) (mkExample {
      literalCode = ''
        mkSplit {
          basePath = "/test";
          itemsPerPage = 2;
          data = range 1 4;
        }
      '';
      code = 
        mkSplit {
          basePath = "/test";
          itemsPerPage = 2;
          data = range 1 4;
        }
      ;
      expected = let 
        pages = [ { path = "/test.html";   index = 1; items = [ 1 2 ]; itemsNb = 2; }
                  { path = "/test-2.html"; index = 2; items = [ 3 4 ]; itemsNb = 2; } ];
        in map (p: p // { inherit pages; }) pages;
    }) ];

    function = {
      basePath
    , itemsPerPage
    , data
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "basePath" "itemsPerPage" "data" ];
        set = { itemsNb = itemsPerPage; };
      in mkSplitCustom ({
        inherit data;
        head = set // { path = "${basePath}.html"; };
        tail = set // { inherit basePath; };
      } // extraArgs);
  };

# -----------------------------

  mkMultipages = documentedFunction {
    description = "Create the list of pages from a multipage data set.";

    arguments = {
      pages = {
        description = "List of subpages data.";
        type = "[ Attrs ]";
      };
      basePath = {
        description = "String used by `pathFn` to generate the page path.";
        type = "String";
      };
      output= {
        description = ''
          The pages to generate:

          * `"all"`: Generate all the pages.
          * `"head"`: Generate only the first page.
          * `"tail"`: Generate all but the first page.
        '';
        type = ''"all" | "head" | "tail"'';
        default = "all";
      };
      pathFn= {
        description = "Function to generate the path of the page.";
        type = ''(Int -> String)'';
        default = literalExample ''i: if i == 1 then "''${basePath}.html" else "''${basePath}-''${toString i}.html"'';
      };
    };

    return = "The page(s) according to the `output` argument.";

    notes = ''
      Any extra arguments will be forwarded to every generated page set.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.about = mkMultipages ({
          template = templates.page.full;
          basepath = "about";
        } // data.about);
      '';
    }) (mkExample {
      literalCode = ''
        mkSplit {
          basePath = "/test";
          itemsPerPage = 2;
          data = range 1 4;
        }
      '';
      code = 
        mkSplit {
          basePath = "/test";
          itemsPerPage = 2;
          data = range 1 4;
        }
      ;
      expected = let 
        pages = [ { path = "/test.html";   index = 1; items = [ 1 2 ]; itemsNb = 2; }
                  { path = "/test-2.html"; index = 2; items = [ 3 4 ]; itemsNb = 2; } ];
        in map (p: p // { inherit pages; }) pages;
    }) ];

    function = {
      pages
    , basePath ? null
    , output   ? "all"
    , pathFn   ? (i: if i == 1 then "${basePath}.html" else "${basePath}-${toString i}.html")
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "basePath" "pathFn" "output" "pages" ];
        subpages = imap (index: page:
          extraArgs // 
          { inherit index;
            path = pathFn index;
          }
          // page
         ) pages;
        pages' = map (p: p // { pages = subpages; rootPage = head subpages; }) subpages;
      in      if output == "all"  then pages'
         else if output == "head" then head pages'
         else if output == "tail" then tail pages'
         else abort "mkMultipage output must be 'all', 'head' or 'tail'";
  };

# -----------------------------

  mkPageList = documentedFunction {
    description = "Generate a list of pages from a list of data set, generates only the first page for multipages data set.";

    arguments = {
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
      pathPrefix = {
        description = "String used by `pathFn` to generate the page path.";
        type = "String";
        default = "";
      };
      multipageTemplate = {
        description = "Template used for multipage data sets.";
        type = "Template";
        default = null;
      };
      pathFn= {
        description = "Function to generate the path of the page.";
        type = ''(Data -> String)'';
        default = literalExample ''data: "''${pathPrefix}''${data.fileData.basename}"'';
      };
    };

    return = "A list of page sets.";

    notes = ''
      * Any extra arguments will be forwarded to every generated page set.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.posts = mkPageList {
          data       = data.posts;
          pathPrefix = "/posts/";
          template   = templates.post.full;
          multipageTemplate = templates.post.full-multipage;
        };
      '';
    }) ];

    function = { 
      data
    , pathPrefix ? ""
    , pathFn ? (data: "${pathPrefix}${data.fileData.basename}")
    , multipageTemplate ? null
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "data" "pathPrefix" "pathFn" "multipageTemplate" ];
        mkPage = data: let
          mpTemplate = if (multipageTemplate != null)
                          then { template = multipageTemplate; }
                          else {};
          page =
            if data ? pages
               then mkMultipages (extraArgs // {
                 output   = "head";
                 basePath = pathFn data;
               } // data // mpTemplate)
               else data;
          in extraArgs // {
               path = "${pathFn data}.html";
              } // page;
      in map mkPage data;
  };

# -----------------------------

  mkMultiTail = documentedFunction {
    description = "Generate a list of multipages subpages tail sets from a list of data set.";

    arguments = {
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
      pathPrefix = {
        description = "String used by `pathFn` to generate the page path.";
        type = "String";
        default = "";
      };
      pathFn= {
        description = "Function to generate the path of the page.";
        type = ''(Data -> String)'';
        default = literalExample ''data: "''${pathPrefix}''${data.fileData.basename}"'';
      };
    };

    return = "A list of page sets.";

    notes = ''
      Any extra arguments will be forwarded to every generated page set.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.postsMultiTail = mkMultiTail {
          data       = data.posts;
          pathPrefix = "/posts/";
          template   = templates.post.full-multipage;
        };
      '';
    }) ];

    function = { 
      data
    , pathPrefix ? ""
    , pathFn ? (data: "${pathPrefix}${data.fileData.basename}")
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "data" "pathFn" "pathPrefix" ];
        mpData = filter (d: (d ? pages)) data;
        mkPage = data:
          mkMultipages (extraArgs // {
            output   = "tail";
            basePath = pathFn data;
          } // data);
      in flatten (map mkPage mpData);
  };

# -----------------------------

  /* Generate taxonomy pages
  */
  mkTaxonomyPages = documentedFunction {
    description = "Generate taxonomy pages from a data set list.";

    arguments = {
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
      taxonomyTemplate = {
        description = "Template used for taxonomy pages.";
        type = "Template";
      };
      termTemplate = {
        description = "Template used for taxonomy term pages.";
        type = "Template";
      };
      taxonomyPathFn= {
        description = "Function to generate the paths of taxonomy pages.";
        type = ''(Taxonomy -> String)'';
        default = literalExample ''ta: "/''${ta}/index.html"'';
      };
      termPathFn= {
        description = "Function to generate the paths of taxonomy term pages.";
        type = ''(Taxonomy -> Term -> String)'';
        default = literalExample ''ta: te: "/''${ta}/''${te}index.html"'';
      };
    };

    examples = [ (mkExample {
      literalCode = ''
        pages.postTaxonomies = mkTaxonomyPages {
          data = data.taxonomies.posts;
          taxonomyTemplate = templates.taxonomy.full;
          termTemplate = templates.taxonomy.term.full;
        };
      '';
    }) ];

    return = "List of taxonomy page attribute sets.";
  
    function = {
      data
    , taxonomyTemplate
    , termTemplate
    , taxonomyPathFn ? (ta:     "/${ta}/index.html")
    , termPathFn     ? (ta: te: "/${ta}/${te}/index.html")
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "data" "taxonomyTemplate" "termTemplate" "taxonomyPathFn" "termPathFn" ];
        taxonomyPages = propMap (taxonomy: terms:
          (extraArgs //
          { inherit terms taxonomy;
            taxonomyData = { taxonomy = terms; };
            path         = taxonomyPathFn taxonomy;
            template     = taxonomyTemplate; })
        ) data; 
        termPages = flatten (propMap (taxonomy: terms:
          propMap (term: values:
            (extraArgs //
            { inherit taxonomy term values;
              path     = termPathFn taxonomy term;
              template = termTemplate; })
          ) terms
        ) data);
    in (termPages ++ taxonomyPages);
  };

}
