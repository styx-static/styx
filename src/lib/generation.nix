# Page and site generation functions

lib: pkgs:
with lib;
with import ./utils.nix lib;

let
  /* Convert a deep set to a list of sets where the key is the path
     Used to prepare substitutions
  */
  setToList = s:
    let
    f = path: set:
      map (key:
        let
          value = set ? key;
          newPath = path ++ [ key ];
          pathString = concatStringsSep "." newPath;
        in
        if isAttrs value
           then f newPath value
           else { "${pathString}" = value; }
      ) (attrNames set);
    in flatten (f [] s);
in

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
  , pageHrefFn ? (page: page.href)
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

      eval "${preGen}"

      # FILES
      # files are copied only if necessary, else they are just linked from the source
      ${concatMapStringsSep "\n" (filesDir: ''
        for file in ${filesDir}/**/*; do

          # Ignoring folders
          if [ -d "$file" ]; then continue; fi

          # output href
          href=$(realpath --relative-to="${filesDir}" "$file")
          mkdir -p $(dirname $out/$href)

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
                href=$(echo "$href" | sed -r 's/[^.]+$/css/')
                [ -f "$out/$href" ] && rm $out/$href
                (
                  lessc $input 2>/dev/null > $out/$href
                  if [ ! -s "$out/$href" ]; then
                    echo "Warning: could not build '$href'"
                  fi
                ) || (
                  [ -f "$out/$href" ] && rm $out/$href
                  echo "Warning: could not build '$href'"
                )
              ;;
              *.s[ac]ss)
                href=$(echo "$href" | sed -r 's/[^.]+$/css/')
                [ -f "$out/$href" ] && rm $out/$href
                (
                  sass $input 2>/dev/null > "$out/$href"
                  if [ ! -s "$out/$href" ]; then
                    echo "Warning: could not build '$href'"
                  fi
                ) || (
                  [ -f "$out/$href" ] && rm "$out/$href"
                  echo "Warning: could not build '$href'"
                )
              ;;
              *)
                [ -f "$out/$href" ] && rm "$out/$href"
                if [ "$hasSubs" ]; then
                  cp "$input" "$out/$href"
                else
                  ln -s "$input" "$out/$href"
                fi;
              ;;
            esac

          else
            [ -f "$out/$href" ] && rm "$out/$href"
            ln -s "$file" "$out/$href"
          fi
        done;
      '') files}

      # PAGES
      ${concatMapStringsSep "\n" (page: ''
        outPath="$out/${pageHrefFn page}"
        page=${pkgs.writeText "${name}-page" (genPageFn page)}
        mkdir -p "$(dirname "$outPath")"
        run_subs "$page"
        if [ $(cmp --silent subs $page || echo 1) ]; then
          cp "subs" "$outPath"
        else
          ln -s "$page" "$outPath"
        fi
      '') pagesList}

      eval "${postGen}"
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
