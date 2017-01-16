# Page and site generation functions

lib: pkgs:
with lib;
with import ./utils.nix lib;

rec {

  /* Generate a page
  */
  generatePage = page: page.layout (page.template page);

  /* Generate a site with a list pages
  */
  generateSite = {
    name ? "styx-site"
  , meta ? {}
  , files ? []
  , pagesList ? []
  , substitutions ? {}
  , preGen  ? ""
  , postGen ? ""
  # extra customization options
  , genPageFn ? generatePage
  , pagePathFn ? (page: page.path)
  }:
    let
      env = {
        meta = { platforms = lib.platforms.all; } // meta;
        buildInputs = [ pkgs.styx ];
      };
    in
    pkgs.runCommand name env ''
      shopt -s globstar
      mkdir -p $out

      # check if a file is a text file
      text_file () {
        file $1 | grep text | cut -d: -f1
      }

      # run substitutions on a file
      # output results to subs
      run_subs () {
        cp $1 subs && chmod u+rw subs
        ${concatMapStringsSep "\n" (set:
          let key   = head (attrNames  set);
              value = head (attrValues set);
          in
          ''
            substituteInPlace subs \
              --subst-var-by "${key}" "${toString value}"
          ''
        ) (setToList substitutions)}
      }

      ${preGen}

      # FILES
      # files are copied only if necessary, else they are just linked from the source
      ${concatMapStringsSep "\n" (filesDir: ''
        for file in ${filesDir}/**/*; do

          # Ignoring folders
          if [ -d "$file" ]; then continue; fi

          # output path
          path=$(realpath --relative-to="${filesDir}" "$file")
          mkdir -p $(dirname $out/$path)

          if [ $(text_file $file) ]; then
            input=$file
            hasSubs=
            run_subs $file

            if [ $(cmp --silent subs $file || echo 1) ]; then
              input=subs
              hasSubs=1
            fi

            case "$file" in
              *.less)
                path=$(echo "$path" | sed -r 's/[^.]+$/css/')
                [ -f "$out/$path" ] && rm $out/$path
                (
                  lessc $input 2>/dev/null > $out/$path
                  if [ ! -s "$out/$path" ]; then
                    echo "Warning: could not build '$path'"
                  fi
                ) || (
                  [ -f "$out/$path" ] && rm $out/$path
                  echo "Warning: could not build '$path'"
                )
              ;;
              *.s[ac]ss)
                path=$(echo "$path" | sed -r 's/[^.]+$/css/')
                [ -f "$out/$path" ] && rm $out/$path
                (
                  sass $input 2>/dev/null > "$out/$path"
                  if [ ! -s "$out/$path" ]; then
                    echo "Warning: could not build '$path'"
                  fi
                ) || (
                  [ -f "$out/$path" ] && rm "$out/$path"
                  echo "Warning: could not build '$path'"
                )
              ;;
              *)
                [ -f "$out/$path" ] && rm "$out/$path"
                if [ "$hasSubs" ]; then
                  cp "$input" "$out/$path"
                else
                  ln -s "$input" "$out/$path"
                fi;
              ;;
            esac

          else
            [ -f "$out/$path" ] && rm "$out/$path"
            ln -s "$file" "$out/$path"
          fi
        done;
      '') files}

      # PAGES
      ${concatMapStringsSep "\n" (page: ''
        outPath="$out${pagePathFn page}"
        page=${pkgs.writeText "${name}-page" (genPageFn page)}
        mkdir -p "$(dirname "$outPath")"
        run_subs "$page"
        if [ $(cmp --silent subs $page || echo 1) ]; then
          cp "subs" "$outPath"
        else
          ln -s "$page" "$outPath"
        fi
      '') pagesList}

      ${postGen}
    '';

  /* Convert a page attribute set to a list of pages
  */
  pagesToList = {
    pages
  , default ? {}
  }:
    let pages' = attrValues pages;
    in fold (p: acc:
         if isList p
         then (map (x: default // x) p) ++ acc
         else [(default // p)] ++ acc
       ) [] pages';

}
