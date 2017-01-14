# Page functions

lib:
with lib;
with import ./utils.nix lib;
with import ./proplist.nix lib;

rec {

  /* Split a list of data between multiple pages
     return a list of pages

     Example:

       index = mkSplitCustom {
         head = {
           title    = "Home";
           path     = "/index.html";
           itemsNb  = 1;
         };
         tail = {
           title    = "Archives";
           basePath = "/archive";
           pathFn   = i: 
           itemsNb  = 2;
         };
         data = posts;
       };

  */
  mkSplitCustom = { head, tail, data, ... }@args:
    let
      extraArgs = removeAttrs args [ "head" "tail" "data" ];
      itemsList = [ (take head.itemsNb data) ] ++ (chunksOf tail.itemsNb (drop head.itemsNb data));
      pathFn = tail.pathFn or (i: "${tail.basePath}-${toString i}.html");
      pages = imap (i: items:
        { inherit items; index = i; }
        // extraArgs
        // (if i ==1
               then head
               else (removeAttrs tail [ "basePath" "pathFn" ]) // { path = pathFn i; })
      ) itemsList;
    in map (p: p // { inherit pages; }) pages;

  /* Split a list of items between multiple pages, mkSplitCustom simple version
     return a list of pages

     Example usage:

       index = mkSplit {
         title        = "Home";
         basePath     = "/index";
         itemsPerPage = 1;
         template     = templates.index;
         data         = posts;
       };

  */
  mkSplit = { basePath, itemsPerPage, data, ... }@args:
    let
      extraArgs = removeAttrs args [ "basePath" "itemsPerPage" "data" ];
      set = { itemsNb = itemsPerPage; };
    in mkSplitCustom ({
      inherit data;
      head = set // { path = "${basePath}.html"; };
      tail = set // { inherit basePath; };
    } // extraArgs);

  /* Split a page with subpages into multiple pages attribute sets
  */
  mkMultipages = { pages, basePath, output ? "all", ... }@args:
    let
      extraArgs = removeAttrs args [ "basePath" "output" "pages" ];
      subpages = imap (index: page:
        extraArgs // 
        { inherit index;
          path = if index == 1 
                 then "${basePath}.html"
                 else "${basePath}-${toString index}.html";
        }
        // page
       ) pages;
      pages' = map (p: p // { pages = subpages; }) subpages;
    in      if output == "all"  then pages'
       else if output == "head" then head pages'
       else if output == "tail" then tail pages'
       else abort "mkMultipage output must be 'all', 'head' or 'tail'";

  /* Make a list of pages, automatically deal with multipages
  */
  mkPageList = { data, pathPrefix ? "", multipageTemplate ? null, ... }@args:
    let
      extraArgs = removeAttrs args [ "data" "pathPrefix" "multipageTemplate" ];
      mkPage = data: let
        mpTemplate = if (multipageTemplate != null)
                        then { template = multipageTemplate; }
                        else {};
        page =
          if data ? pages
             then mkMultipages (extraArgs // {
               output = "head";
               basePath = "${pathPrefix}${data.fileData.basename}";
             } // data // mpTemplate)
             else data;
        in extraArgs // {
             path = "${pathPrefix}${data.fileData.basename}.html";
            } // page;
    in map mkPage data;

  /* generates a the tails pages of the multipages of a list
  */
  mkMultiTail = { data, pathPrefix ? "", ... }@args:
    let
      extraArgs = removeAttrs args [ "data" "pathPrefix" ];
      mpData = filter (d: (d ? pages)) data;
      mkPage = data:
        mkMultipages (extraArgs // {
          output = "tail";
          basePath = "${pathPrefix}${data.fileData.basename}";
        } // data);
    in flatten (map mkPage mpData);

  /* Generate taxonomy pages
  */
  mkTaxonomyPages =
  { data
  , taxonomyTemplate
  , termTemplate
  , taxonomyPathFn ? (ta:     "/${ta}/index.html")
  , termPathFn     ? (ta: te: "/${ta}/${te}/index.html")
  , ...
  }@args:
    let
      extraArgs = removeAttrs args [ "data" "taxonomyTemplate" "termTemplate" "taxonomyPathFn" "termPathFn" ];
      taxonomyPages = map (plist:
        let taxonomy = propKey   plist;
            terms    = propValue plist;
        in
        (extraArgs //
        { inherit terms taxonomy;
          taxonomyData = plist;
          path = taxonomyPathFn taxonomy;
          template = taxonomyTemplate; })
      ) data; 
      termPages = flatten (map (plist:
        let taxonomy = propKey   plist;
            terms    = propValue plist;
        in
        map (term:
          (extraArgs //
          { inherit taxonomy;
            path     = termPathFn taxonomy (propKey term);
            template = termTemplate;
            term     = propKey   term;
            values   = propValue term; })
        ) terms
      ) data);
  in (termPages ++ taxonomyPages);

}
