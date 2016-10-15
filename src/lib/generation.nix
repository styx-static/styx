# Page and site generation functions

lib: pkgs:
with lib;
with import ./utils.nix lib;

rec {

  /* Generate a site with a list pages
  */
  generateSite = {
    files ? []
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

}
