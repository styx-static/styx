# Page functions

lib:
with lib;
with import ./utils.nix lib;
let
  plib = import ./proplist.nix lib;
in

rec {

  /* Split a list of data between multiple pages
     return a list of pages

     Example:

       index = mkSplitCustom {
         head = {
           title    = "Home";
           href     = "index.html";
           itemsNb  = 1;
         };
         tail = {
           title    = "Archives";
           baseHref = "archive";
           itemsNb  = 2;
         };
         data = posts;
       };

  */
  mkSplitCustom = { head, tail, data, ... }@args:
    let
      extraArgs = removeAttrs args [ "head" "tail" "data" ];
      itemsList = [ (take head.itemsNb data) ] ++ (chunksOf tail.itemsNb (drop head.itemsNb data));
      pages = imap (i: items:
        { inherit items; index = i; }
        // extraArgs
        // (if i ==1
               then head
               else (removeAttrs tail [ "baseHref" ]) // { href = "${tail.baseHref}-${toString i}.html"; })
      ) itemsList;
    in map (p: p // { inherit pages; }) pages;

  /* Split a list of items between multiple pages, mkSplitCustom simple version
     return a list of pages

     Example usage:

       index = mkSplit {
         title = "Home";
         baseHref = "index";
         itemsPerPage = 1;
         template = templates.index;
         data = posts;
       };

  */
  mkSplit = { baseHref, itemsPerPage, data, ... }@args:
    let
      extraArgs = removeAttrs args [ "baseHref" "itemsPerPage" "data" ];
      set = { itemsNb = itemsPerPage; };
    in mkSplitCustom ({
      inherit data;
      head = set // { href = "${baseHref}.html"; };
      tail = set // { inherit baseHref; };
    } // extraArgs);

  /* Split a page with subpages into multiple pages attribute sets
  */
  mkMultipages = { subpages, baseHref, output ? "all", ... }@args:
    let
      extraArgs = removeAttrs args [ "baseHref" "output" ];
      pages = imap (index: subpage:
        extraArgs // 
          { inherit index;
            href = if index == 1 
                   then "${baseHref}.html"
                   else "${baseHref}-${toString index}.html";
            content = subpage; }
       ) subpages;
      pages' = map (p: p // { inherit pages; }) pages;
    in      if output == "all" then pages
       else if output == "head" then head pages'
       else if output == "tail" then tail pages'
       else abort "mkMultipage output must be 'all', 'head' or 'tail'";

  mkPageList = { data, hrefPrefix ? "", multipageTemplate ? null, ... }@args:
    let
      extraArgs = removeAttrs args [ "data" "hrefPrefix" "multipageTemplate" ];
      mkPage = data: let
        mpTemplate = if (multipageTemplate != null)
                        then { template = multipageTemplate; }
                        else {};
        page =
          if data ? subpages
             then mkMultipages (extraArgs // {
               output = "head";
               baseHref = "${hrefPrefix}${data.fileData.basename}";
             } // data // mpTemplate)
             else data;
        in extraArgs // {
             href = "${hrefPrefix}${data.fileData.basename}.html";
            } // page;
    in map mkPage data;

  /* generates a the tails pages of the multipages of a list
  */
  mkMultiTail = { data, hrefPrefix ? "", ... }@args:
    let
      extraArgs = removeAttrs args [ "data" "hrefPrefix" ];
      mpData = filter (d: (d ? subpages)) data;
      mkPage = data:
        mkMultipages (extraArgs // {
          output = "tail";
          baseHref = "${hrefPrefix}${data.fileData.basename}";
        } // data);
    in flatten (map mkPage mpData);

  /* Generate taxonomy pages
  */
  mkTaxonomyPages =
  { data
  , taxonomyTemplate
  , termTemplate
  , taxonomyHrefFun ? (t: "${t}/index.html")
  , termHrefFun ? (ta: te: "${ta}/${te}/index.html")
  }:
    let
      taxonomyPages = map (plist:
        let taxonomy = plib.propKey   plist;
            terms    = plib.propValue plist;
        in
        { inherit terms taxonomy;
          href = taxonomyHrefFun taxonomy;
          template = taxonomyTemplate;
          title = taxonomy; }
      ) data; 
      termPages = flatten (map (plist:
        let taxonomy = plib.propKey   plist;
            terms    = plib.propValue plist;
        in
        map (term:
          { inherit taxonomy;
            href     = termHrefFun taxonomy (plib.propKey term);
            template = termTemplate;
            title    = plib.propKey   term;
            term     = plib.propKey   term;
            values   = plib.propValue term; }
        ) terms
      ) data);
  in (termPages ++ taxonomyPages);

  /* Set a default layout to a page attribute set
     Does nothing if a layout is already set
  */
  setDefaultLayout = layout: page:
    if page ? layout
       then page
       else page // { inherit layout; };

}
