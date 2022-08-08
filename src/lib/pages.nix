# Page functions

{lib, ...}@args:
with lib;
with import ./utils.nix args;
with import ./proplist.nix args;

rec {

/*
===============================================================

 mkSplitPagePath

===============================================================
*/

  mkSplitPagePath = documentedFunction {
    description = "Function to generate a splitted page path.";

    arguments = {
      index = {
        description = "Index of the page.";
        type = "Int";
      };
      pre = {
        description = "String to add at the beginning of the path.";
        type = "String";
      };
      post = {
        description = "String to add at the end of the path.";
        type = "String";
        default = ".html";
      };
    };

    return = "Page path.";

    examples = [(mkExample {
      literalCode = ''
        mkSplitPagePath {
          index = 1;
          pre = "/foo";
        }
      '';
      code =
        mkSplitPagePath {
          index = 1;
          pre = "/foo";
        }
      ;
      expected = "/foo.html";
    }) (mkExample {
      literalCode = ''
        mkSplitPagePath {
          index = 3;
          pre = "/foo";
        }
      '';
      code =
        mkSplitPagePath {
          index = 3;
          pre = "/foo";
        }
      ;
      expected = "/foo-3.html";
    })];

    function = {
      index
    , pre
    , post ? ".html"
    }:
      if index == 1
      then "${pre}${post}"
      else "${pre}-${toString index}${post}";
  };

/*
===============================================================

 mkSplitCustom

===============================================================
*/

  mkSplitCustom = documentedFunction {
    description = "Create a list of pages from a list of data.";

    arguments = {
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
      pageFn = {
        description = ''
          A function to apply to each data set, takes the index of the page and a data set and return a page set. +
          Must set `itemsNb`, the number of item to have on the page, and `path` to generate valid pages.
        '';
        type = "Int -> Data -> Page";
        example = literalExpression ''
          index: data: {
            itemsNb = if index == 1 then 3 else 5;
            path = if index == 1 then "/index.html" else "/archive-''${toString index}.html";
          }
        '';
      };
    };

    return = ''
      List of pages. Each page has:

      * `items`: List of the page data items.
      * `pages`: List of splitted pages.
    '';

    examples = [(mkExample {
      literalCode = ''
        mkSplitCustom {
          data = map (x: { id = x; }) (range 1 4);
          pageFn = (index: data: {
            itemsNb = if index == 1 then 3 else 5;
            path    = if index == 1 then "/index.html" else "/archive-''${toString index}.html";
          });
        }
      '';
      displayCode = map (x: x // { pages = literalExpression "[ ... ]"; });
      code =
        mkSplitCustom {
          data = map (x: { id = x; }) (range 1 4);
          pageFn = (index: data: {
            itemsNb = if index == 1 then 1 else 2;
            path = if index == 1 then "/index.html" else "/archive-${toString index}.html";
          });
        }
      ;
      expected = 
        let 
          pages = [
            { index = 1; items = [ { id = 1; } ]; path = "/index.html"; }
            { index = 2; items = [ { id = 2; } { id = 3; } ]; path = "/archive-2.html"; }
            { index = 3; items = [ { id = 4; } ]; path = "/archive-3.html"; }
          ];
        in map (p: p // { inherit pages; }) pages
      ;
    })];

    function = {
      data
    , pageFn
    }:
     let
       loop = index: data: pages:
         let
           index'  = index + 1;
           itemsNb = (pageFn index (head data)).itemsNb;
           items   = take itemsNb data;
           pages'  = pages ++ [ ((removeAttrs (pageFn index data) [ "itemsNb" ]) // { inherit index items; }) ];
           data'   = drop itemsNb data;
         in if data == []
            then pages
            else loop index' data' pages';
       pages = loop 1 data [];
     in map (p: p // { inherit pages; }) pages;
  };


/*
===============================================================

 mkSplit

===============================================================
*/

  mkSplit = documentedFunction {
    description = "Create a list of pages from a list of data.";

    arguments = {
      basePath = {
        description = ''
          Base path of the generated pages. First page path will be "``basePath``.html", follwing pages "``basePath``-``index``.html"
        '';
        type = "Attrs";
      };
      itemsPerPage = {
        description = ''
          Number of data items to allocate to a page.
        '';
        type = "Int";
      };
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
    };

    return = ''
      List of pages. Each page has:

      * `items`: List of the page data items.
      * `pages`: List of splitted pages.
    '';

    notes = ''
      Any extra arguments will be forwarded to every generated page set.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.archives = mkSplit {
          basePath     = "/archives";
          itemsPerPage = 10;
          data         = pages.posts;
          template     = templates.archives;
        };
      '';
    }) (mkExample {
      literalCode = ''
        mkSplit {
          data = map (x: { id = x; }) (range 1 4);
          itemsPerPage = 2;
          basePath = "/test";
        }
      '';
      displayCode = map (x: x // { pages = literalExpression "[ ... ]"; });
      code =
        mkSplit {
          data = map (x: { id = x; }) (range 1 4);
          itemsPerPage = 2;
          basePath = "/test";
        }
      ;
      expected = 
        let 
          pages = [
            { index = 1; items = [ { id = 1; } { id = 2; } ]; path = "/test.html"; }
            { index = 2; items = [ { id = 3; } { id = 4; } ]; path = "/test-2.html"; }
          ];
        in map (p: p // { inherit pages; }) pages
      ;
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
        pageFn = (index: data:
          extraArgs // {
            path = mkSplitPagePath { inherit index; pre = basePath; };
            itemsNb = itemsPerPage;
          });
      });
  };

/*
===============================================================

 mkMultiPages

===============================================================
*/

  mkMultipages = documentedFunction {
    description = "Create the list of pages from a multipage data set.";

    arguments = {
      pages = {
        description = "List of subpages data.";
        type = "[ Attrs ]";
      };
      basePath = {
        description = "String used by `pathFn` to generate the page path. Used in `pageFn` default, ignored if `pageFn` is set.";
        type = "String";
        default = null;
      };
      pageFn= {
        description = "Function to generate extra attributes to merge to the page.";
        type = "Int -> Data -> Page";
        default = literalExpression ''
          index: data:
            optionalAttrs (basePath != null) {
              path = mkSplitPagePath { inherit index; pre = basePath; };
            }
          '';
      };
    };

    return = ''
      Pages according to the `output`. +
      Every page will get a `multipages` attribute containing:

      - `pages`: list of all the subpages.
      - `index`: Index of the page in the `subpages` list.

    '';

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
      code =
        mkMultipages {
          basePath = "/test";
          title = "Multipage test";
          pages = map (x: { content = "page ${toString x}"; }) (range 1 3);
        }
      ;
      expected = 
        let pages = [
          { content = "page 1"; title = "Multipage test"; path = "/test.html"; }
          { content = "page 2"; title = "Multipage test"; path = "/test-2.html"; }
          { content = "page 3"; title = "Multipage test"; path = "/test-3.html"; }
        ];
        in imap (index: page: page // { multipages = { inherit pages index; }; }) pages 
      ;
    }) ];

    function = {
      pages
    , basePath ? null
    , pageFn   ? null
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "basePath" "pageFn" "output" "pages" ];
        defPageFn = index: data: (
          optionalAttrs (basePath != null) {
            path = mkSplitPagePath { inherit index; pre = basePath; };
          }
        );
        pageFn' =  if pageFn == null then defPageFn else pageFn;
        subpages = imap (index: page:
             extraArgs
          // (pageFn' index page)
          // (removeAttrs page [ "pages" ])
         ) pages;
      in
        imap (index: p: p // { multipages = { pages = subpages; inherit index; }; }) subpages;
  };



/*
===============================================================

 mkPageList

===============================================================
*/

  mkPageList = documentedFunction {
    description = "Generate a list of pages from a list of data set.";

    arguments = {
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
      pathPrefix = {
        description = "String used by `pathFn` and `multipagePathFn` to generate the page path.";
        type = "String";
        default = "";
      };
      pageFn = {
        description = "Function to generate extra attributes of normal pages.";
        type = ''(Data -> Attrs)'';
        default = literalExpression ''data: { path = "''${pathPrefix}''${data.fileData.basename}.html"; }'';
      };
      multipageFn = {
        description = "Function to generate extra attributes of mutipages.";
        type = "Int -> Data -> Attrs";
        default = literalExpression ''
          index: data: {
            path = mkSplitPagePath { pre = "''${pathPrefix}''${data.fileData.basename}"; inherit index; };
          }
        '';
      };
    };

    return = ''
      An attribute set with the following attributes:.

      - `list`: The list of contents, containing single pages and first page of multipages posts.
      - `pages`: List of all pages, including multipages subpages.
    '';

    notes = ''
      * Any extra arguments will be forwarded to every generated page set.
    '';

    examples = [ (mkExample {
      literalCode = ''
        pages.posts = mkPageList {
          data       = data.posts;
          pathPrefix = "/posts/";
          template   = templates.post.full;
        };
      '';
    }) (mkExample {
      code =
        (mkPageList {
          pageFn = data: { path = "/test/${data.id}.html"; };
          multipageFn = index: data: {
            path = "/${data.id}.html";
          };
          data = [
            { content = "normal page 1"; id = "foo"; }
            { pages = [ { content = "multi page 1"; id = "bar"; } { content = "multi page 2"; id = "buz"; } ]; }
            { content = "normal page 2"; id = "baz"; }
          ];
          template = "id";
        })
      ;
      expected =
        let
          mpages = [
            { content = "multi page 1"; id = "bar"; path = "/bar.html"; template = "id"; } 
            { content = "multi page 2"; id = "buz"; path = "/buz.html"; template = "id"; } 
          ];
          listpages = [
            { content = "normal page 1"; id = "foo"; path = "/test/foo.html"; template = "id"; }
            { content = "multi page 1";  id = "bar"; path = "/bar.html"; template = "id"; multipages = { index = 1; pages = mpages; }; }
            { content = "normal page 2"; id = "baz"; path = "/test/baz.html"; template = "id"; }
          ];
          list = imap (index: p: p // { pageList = { inherit index; pages = listpages; }; }) listpages;
          extra = map (p: p // { pageList = { index = 2; pages = listpages; }; multipages = { index = 2; pages = mpages; }; }) (tail mpages); 
        in { _type = "pages"; inherit list; pages = list ++ extra; };
    })];

    function = {
      data
    , pathPrefix ? ""
    , pageFn      ? (data: { path = "${pathPrefix}${data.fileData.basename}.html"; })
    , multipageFn ? (index: data: { path = mkSplitPagePath { pre = "${pathPrefix}${data.fileData.basename}"; inherit index; }; })
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "data" "pathPrefix" "multipageFn" "pageFn" ];
        base = { list = []; extra = []; _id = 0; };
        fn = d: acc: 
          let
            mpages = map (p: p // { _plid = acc._id; }) (mkMultipages (extraArgs // d // { pageFn = multipageFn; }));
            page   = (extraArgs // d // (pageFn d));
            list   =  if d ? pages
                      then [ (head mpages) ]
                      else [ page ];
            extra = optionals (d ? pages) (tail mpages);
          in 
             acc
          // { list = list ++ acc.list; extra = extra ++ acc.extra; _id = acc._id + 1; }
          // (optionalAttrs (d ? _attrName) { "${d._attrName}" = head list; })
        ;
        raw = fold fn base data';
        data' = if isAttrs data
                then mapAttrsToList (n: v: v // { _attrName = n; }) data
                else data;
        cleanlist = l: map (p: removeAttrs p ["_plid"]) l;
        dirtylist = imap (index: p: p // { pageList = { pages = cleanlist raw.list; inherit index; }; }) raw.list;
        list = cleanlist dirtylist;
        extra = cleanlist (map (p: p // { pageList = (findFirst (x: x ? _plid && x._plid == p._plid) "" dirtylist).pageList; }) raw.extra);
      in mkPages ({ inherit list; pages = list ++ extra; } // (removeAttrs raw ["list" "extra" "_id"]));

  };



/*
===============================================================

 mkPages

===============================================================
*/

  mkPages = documentedFunction {
    description = ''
      Generate a pages attribute set. It is used to produce multiple "outputs" by pages generating functions like `mkPageList`. +
      `pagesToList` will only generate the `pages` attribute from a pages attribute set.
    '';

    arguments = {
      pages = {
        description = "List of pages to generate.";
        type = "[ Page ]";
      };
    };

    return = "A pages attribute set.";

    notes = ''
      Any extra argument will be added to the pages set.
    '';

    function = {
      pages
    , ... }@args:
      let
        extraArgs = removeAttrs args [ "pages" ];
      in extraArgs // {
        _type = "pages";
        inherit pages;
      };
  };



/*
===============================================================

 mkTaxonomyPages

===============================================================
*/

  mkTaxonomyPages = documentedFunction {
    description = "Generate taxonomy pages from a data set list.";

    arguments = {
      data = {
        description = "List of data sets.";
        type = "[ Data ]";
      };
      taxonomyPageFn = {
        description = "Function to add extra attributes to the taxonomy page set.";
        type = ''(String -> Page)'';
        default = literalExpression ''taxonomy: {}'';
      };
      termPageFn = {
        description = "Function to add extra attributes to the taxonomy page set.";
        type = ''(String -> String -> Page)'';
        default = literalExpression ''taxonomy: term: {}'';
      };
      taxonomyTemplate = {
        description = "Template used for taxonomy pages.";
        type = "Null | Template";
      };
      termTemplate = {
        description = "Template used for taxonomy term pages.";
        type = "Null | Template";
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
    , taxonomyTemplate ? null
    , termTemplate     ? null
    , taxonomyPageFn   ? (taxonomy: {})
    , termPageFn       ? (taxonomy: term: {})
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "data" "taxonomyTemplate" "termTemplate" "taxonomyPageFn" "termPageFn" ];
        taxonomyPages = propMap (taxonomy: terms:
             extraArgs
          // (optionalAttrs (taxonomyTemplate != null) { template = taxonomyTemplate; })
          // { path = mkTaxonomyPath taxonomy; }
          // { inherit terms taxonomy;
               taxonomyData = { "${taxonomy}" = terms; }; }
          // (taxonomyPageFn taxonomy)
        ) data;
        termPages = flatten (propMap (taxonomy: terms:
          propMap (term: values:
               extraArgs
            // (optionalAttrs (termTemplate != null) { template = termTemplate; })
            // { path = mkTaxonomyTermPath taxonomy term; }
            // { inherit taxonomy term values; }
            // (termPageFn taxonomy term)
          ) terms
        ) data);
    in (termPages ++ taxonomyPages);
  };


/*
===============================================================

 mkTaxonomyPath

===============================================================
*/

  mkTaxonomyPath = documentedFunction {
    description = "Generate a taxonomy page path.";

    arguments = [
      {
        name = "taxonomy";
        type = "String";
      }
    ];

    return = "Taxonomy page path.";

    examples = [(mkExample {
      literalCode = ''
        mkTaxonomyPath "tags"
      '';
      code =
        mkTaxonomyPath "tags"
      ;
      expected = "/tags/index.html";
    }) ];

    function = taxonomy: "/${taxonomy}/index.html";
  };


/*
===============================================================

 mkTaxonomyTermPath

===============================================================
*/

  mkTaxonomyTermPath = documentedFunction {
    description = "Generate a taxonomy term page path.";

    arguments = [
      {
        name = "taxonomy";
        type = "String";
      }
      {
        name = "term";
        type = "String";
      }
    ];

    return = "Taxonomy term page path.";

    examples = [(mkExample {
      literalCode = ''
        mkTaxonomyTermPath "tags" "styx"
      '';
      code =
        mkTaxonomyTermPath "tags" "styx"
      ;
      expected = "/tags/styx/index.html";
    }) ];

    function = taxonomy: term: "/${taxonomy}/${term}/index.html";
  };

}
