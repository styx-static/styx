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

{

  /* Generate a site with a list pages
  */
  generateSite = {
    files
  , pagesList
  , preGen ? ""
  , postGen ? ""
  }:
    pkgs.runCommand "styx-site" {} ''
      mkdir -p $out

      ${concatMapStringsSep "\n" (filesDir: ''
      (
        cd ${filesDir}
        for file in ./*; do
          if [ ! -e "$out/$file" ]; then
            echo $file
            ln -s "$(pwd)/$file" "$out/$file"
          fi
        done
      )
      '') files}

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

  /* Split a page in multiple pages with a list of itemsPerPage items
     Return a list of pages
  */
  splitPage = { baseHref, items, template, itemsPerPage, ... }@args:
    let
      itemsList = chunksOf itemsPerPage items;
      pages = imap (i: items: {
        inherit template items;
        href = if i == 1 then "${baseHref}.html"
               else "${baseHref}-${toString i}.html";
        index = i;
      } // (removeAttrs args ["baseHref" "items" "template" "itemsPerPage"])
      ) itemsList;
    in map (p: p // { inherit pages; }) pages;

}
