# Page and site generation functions

lib: pkgs:
with lib;

let

  chunksOf = k:
    let f = ys: xs:
        if xs == []
           then ys
           else f (ys ++ [(take k xs)]) (drop k xs);
    in f [];

in

rec {

  /* Generate a site with a list pages
  */
  generateSite = {
    files
  , pagesList
  , preGen  ? ""
  , postGen ? ""
  , enablePreprocessors ? false
  }:
    pkgs.runCommand "styx-site" {} ''
      shopt -s globstar
      mkdir -p $out

      eval "${preGen}"

      # Copying files
      ${concatMapStringsSep "\n" (filesDir:
        if enablePreprocessors then ''

          cp -r ${filesDir}/* $out
          chmod u+rw -R $out/

          # convert sass / scss
          for i in $out/**/*.s[ac]ss; do
            ${pkgs.sass}/bin/sass $i > "$(realpath $i | cut -d'.' -f1).css"
            rm $i
          done

          # convert less
          for i in $out/**/*.less; do
            ${pkgs.lessc}/bin/lessc $i > "$(realpath $i | cut -d'.' -f1).css"
            rm $i
          done

        '' else ''
        (
          cd ${filesDir}
          for file in ./*; do
            if [ ! -e "$out/$file" ]; then
              ln -s "$(pwd)/$file" "$out/$file"
            fi
          done
        )
        '') files}

      # Generating pages
      ${concatMapStringsSep "\n" (page: ''
        mkdir -p $(dirname $out/${page.href})
        ln -s ${pkgs.writeText "styx-site-${replaceStrings ["/"] ["-"] page.href}" (page.layout (page.template page)) } $out/${page.href}
      '') pagesList}

      eval "${postGen}"
    '';

  /* Convert a page attribute set to a list of pages
  */
  pagesToList = pages:
    let
      pages' = attrValues pages;
    in fold
         (y: x: if isList y then x ++ y else x ++ [y])
         [] pages';

  /* Split a list of items between multiple pages
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
         template = templates.index;
         items = posts;
       };

  */
  mkSplitCustom = { head, tail, items, ... }@args:
    let
      extraArgs = removeAttrs args [ "head" "tail" "items" ];
      itemsList = [ (take head.itemsNb items) ] ++ (chunksOf tail.itemsNb (drop head.itemsNb items));
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
         items = posts;
       };

  */
  mkSplit = { baseHref, itemsPerPage, items, ... }@args:
    let
      extraArgs = removeAttrs args [ "baseHref" "itemsPerPage" "items" ];
      set = { itemsNb = itemsPerPage; };
    in mkSplitCustom ({
      inherit items;
      head = set // { href = "${baseHref}.html"; };
      tail = set // { inherit baseHref; };
    } // extraArgs);

}
