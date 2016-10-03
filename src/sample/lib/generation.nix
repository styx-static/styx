# Page and site generation functions

with import ./nixpkgs-lib.nix;

let
  pkgs = import (import ../nixpkgs-path.nix) {};
in

{
  /* Generate the index page
  */
  generateIndex = template: groupedPosts: {
    inherit template;
    href     = "index.html";
    posts    = groupedPosts.index;
    nextPage = if length groupedPosts.archive > 1
               then "archive-1.html"
               else null;
  };

  /* Generate the archives pages
  */
  generateArchives = template: groupedPosts:
    imap (i: posts: {
      inherit posts template;
      href     = "archive-${toString i}.html";
      nextPage = if length archivePosts >= i + 1
                    then "archive-${toString (i + 1)}.html"
                    else null;
      prevPage = if i == 1
                    then "index.html"
                    else "archive-${toString (i - 1)}.html";
    }) groupedPosts.archive;

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
