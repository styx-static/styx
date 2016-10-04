# Page and site generation functions

with import ./nixpkgs-lib.nix;

let
  pkgs = import ./pkgs.nix;

  chunksOf = k:
    let f = ys: xs:
        if xs == []
           then ys
           else f (ys ++ [(take k xs)]) (drop k xs);
    in f [];

in

{
  /* Generate a blog archives pages
  */
  generateBlogArchives = template: groupedPosts:
    imap (i: posts: {
      inherit posts template;
      href     = "archive-${toString i}.html";
      nextPage = if length posts >= i + 1
                    then "archive-${toString (i + 1)}.html"
                    else null;
      prevPage = if i == 1
                    then "index.html"
                    else "archive-${toString (i - 1)}.html";
    }) groupedPosts.archive;

  /* Split a page in multiple pages with a list of itemsPerPage items
     Return a list of pages
  */
  splitPage = { baseHref, items, template, itemsPerPage }:
    let
      itemsList = chunksOf itemsPerPage items;
      pages = imap (i: items: {
        inherit template items;
        href = if i == 1 then "${baseHref}.html"
               else "${baseHref}-${toString i}.html";
        index = i;
      }) itemsList;
    in map (p: p // { inherit pages; }) pages;


  /* Generate a site with pages
  */
  generateBasicSite = {
    conf
  , pages
  , preInstall ? ""
  , postInstall ? ""
  }:
    pkgs.runCommand conf.siteId {} ''
      mkdir -p $out

      eval "${preInstall}"

      for file in ${conf.staticDir}/*; do
        ln -s $file $out/
      done

      ${concatMapStringsSep "\n" (page: ''
        mkdir -p `dirname $out/${page.href}`
        ln -s ${pkgs.writeText "${conf.siteId}-${replaceStrings ["/"] ["-"] page.href}" (page.template page) } $out/${page.href}
      '') pages}

      echo "${conf.siteUrl}" > $out/CNAME
      sed -i -e "s|https://||" $out/CNAME
      sed -i -e "s|http://||" $out/CNAME

      touch $out/.nojekyll

      eval "${postInstall}"
    '';
}
