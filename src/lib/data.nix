# Data functions

lib: pkgs:
with lib;

let

  /* Supported content types
  */
  supportedFiles = nixExt ++ markdownExt;

  nixExt = [ "nix" ];
  markdownExt = [ "md" "markdown" ];

  /* Add more when we support more markups types
  */
  markupExt = markdownExt;

  /* Parse a markup file to an attribute set
     Extract what it can
  */
  parseMarkupFile = { fileData, substitutions }:
    let
      path = "${fileData.dir + "/${fileData.name}"}";
      data = pkgs.runCommand "data" {} ''
        # metablock separator
        metaBlock="/{---/,/---}/p"
        # pageSeparator
        pageSep="<<<"
        # intro separator
        introSep=">>>"

        mkdir $out

        # initializing files
        cp ${path} $out/source
        chmod u+rw $out/source
        touch $out/intro
        touch $out/title
        touch $out/content
        echo "{}" > $out/meta
        mkdir $out/subpages

        # metadata
        if [ "$(sed -n "$metaBlock" < $out/source)" ]; then
          echo "{" > $out/meta
          sed -n "$metaBlock" < $out/source | sed '1d;$d' >> $out/meta
          echo "}" >> $out/meta
          sed -i "1,$(cat $out/meta | wc -l)d" $out/source
        fi

        # intro
        if [ "$(grep -Fx "$introSep" $out/source)" ]; then
          csplit -s -f intro $out/source "/^>>>$/"
          cp intro00 $out/intro
          sed -i "/$introSep/d" $out/source
        fi

        # subpages
        if [ "$(grep -Fx "$pageSep" $out/source)" ]; then
          csplit --suppress-matched -s -f subpage $out/source  "/^$pageSep/" '{*}'
          cp subpage* $out/subpages
          sed -i "/$pageSep/d" $out/source
        fi

        # substitutions
        ${concatMapStringsSep "\n" (set:
          let
            key   = head (attrNames  set);
            value = head (attrValues set);
          in
          ''
            substituteInPlace $out/source \
              --subst-var-by ${key} ${value}
          ''
        ) (setToList substitutions)}


        # Converting markup files
        ${optionalString (elem fileData.ext markdownExt) '' 
          ${pkgs.multimarkdown}/bin/multimarkdown < $out/source > $out/content

          # intro
          cp $out/intro tmp; ${pkgs.multimarkdown}/bin/multimarkdown < tmp > $out/intro

          # subpages
          for file in $out/subpages/*; do
            cp $file tmp; ${pkgs.multimarkdown}/bin/multimarkdown < tmp > $file
          done

          # title
          ${pkgs.xidel}/bin/xidel $out/content -e "//h1[1]/node()" -q > $out/title
          echo -n `tr -d '\n' < $out/title` > $out/title
        ''}
      '';
      content = let
          rawContent = readFile "${data}/content";
        in if rawContent == "" then {} else { content = rawContent; } ;
      title = let
          rawContent = readFile "${data}/title";
        in if rawContent == "" then {} else { title = rawContent; };
      intro = let
          rawContent = readFile "${data}/intro";
        in if rawContent == "" then {} else { intro = rawContent; };
      subpages = let
          dir = "${data}/subpages";
          subpages = mapAttrsToList (k: v:
            readFile "${dir}/${k}"
          ) (readDir dir);
        in if subpages != []
              then { inherit subpages; }
              else { };

      meta = import "${data}/meta";
    in
      content // title // intro // meta // subpages;

  /* Get data from a file
  */
  parseFile = { fileData, substitutions }@args:
    let
      m = match "^(....-..-..)-(.*)" fileData.basename;
      date = if m != null then { date = (elemAt m 0); } else {};
      path = "${fileData.dir + "/${fileData.name}"}";
      data = if elem fileData.ext markupExt then parseMarkupFile args
             else if fileData.ext == "nix" then import path
             else trace "Error: this should never happen.";
    in
      { inherit fileData; } // date // data;

  /* Convert a deep set to a list of sets where the key is the path
     Used to prepare substitutions
  */
  setToList = s:
    let
    f = path: set:
      map (key:
        let
          value = set.${key};
          newPath = path ++ [ key ];
          pathString = concatStringsSep "." newPath;
        in
        if isAttrs value
           then f newPath value
           else { "${pathString}" = toString value; }
      ) (attrNames set);
    in flatten (f [] s);

  /* Get a list of files data from a folder
     Ignore unsupported files type

     Return example

       [ { basename = "file"; ext = "nix"; name = "file.nix"; dir = "/foo/bar"; } ]
  */
  getFiles = from:
    let
      fileList = mapAttrsToList (k: v:
        let 
          m = match "^(.*)\\.([^.]+)$" k;
          basename = elemAt m 0;
          ext = elemAt m 1;
        in
        if (v == "regular") && (m != null) && (elem ext supportedFiles)
           then { inherit basename ext; dir = from; name = k; }
           else trace "File '${k}' is not a supported file and will be ignored." null
      ) (readDir from);
    in filter (x: x != null) fileList;

in
rec {

  /* load the data files from a folder that styx can handle
  */
  loadFolder = { from, substitutions ? {}, extraAttrs ? {} }:
    map (fileData:
      (parseFile { inherit fileData substitutions; }) // extraAttrs
    ) (getFiles from);

  /* load a data file
  */
  loadFile = { dir, file, substitutions ? {}, extraAttrs ? {} }:
    let
      m = match "^(.*)\\.([^.]+)$" file;
      basename = elemAt m 0;
      ext = elemAt m 1;
      fileData = { inherit dir basename ext; name = file; };
    in
      (parseFile { inherit substitutions fileData; }) // extraAttrs;

  /* Sort a list of pages chronologically
  */
  sortBy = attribute: order: 
    sort (a: b: 
           if order == "asc" then a."${attribute}" < b."${attribute}"
      else if order == "dsc" then a."${attribute}" > b."${attribute}"
      else    abort "Sort order must be 'asc' or 'dsc'");

  /* Convert a markdown string to html
  */
  markdownToHtml = text:
    let
      data = pkgs.runCommand "data" {} ''
        mkdir $out
        echo -n "${text}" > $out/source
        ${pkgs.multimarkdown}/bin/multimarkdown < $out/source > $out/content
      '';
    in readFile "${data}/content";

}
