# Data functions

lib: pkgs:
with lib;
with (import ./proplist.nix lib);

let

  /* Supported content types
  */
  supportedFiles = flatten (attrValues ext);

  ext = {
    # markups
    asciidoc = [ "asciidoc" "adoc" ];
    markdown = [ "markdown" "mdown" "md" ];
    # other
    nix      = [ "nix" ];
  };

  markupExts = ext.asciidoc ++ ext.markdown;

  /* Convert commands
  */
  commands = {
    asciidoc = "${pkgs.asciidoctor}/bin/asciidoctor -s -a showtitle -o-";
    markdown = "${pkgs.multimarkdown}/bin/multimarkdown";
  };

  /* Parse a markup file to an attribute set
     Extract what it can
  */
  parseMarkupFile = { fileData, substitutions }:
    let
      markupType = head (attrNames (filterAttrs (k: v: elem fileData.ext v) ext));
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

        # intro
        if [ "$(grep -Fx "$introSep" $out/source)" ]; then
          csplit -s -f intro $out/source "/^$introSep$/"
          cp intro00 $out/intro
          sed -i "/$introSep/d" $out/source
        fi

        # subpages
        if [ "$(grep -Fx "$pageSep" $out/source)" ]; then
          csplit --suppress-matched -s -f subpage $out/source  "/^$pageSep/" '{*}'
          cp subpage* $out/subpages
          sed -i "/$pageSep/d" $out/source
        fi

        # Converting markup files
        ${commands."${markupType}"} $out/source > $out/content

        # intro
        cp $out/intro tmp; ${commands."${markupType}"} tmp | tr -d '\n' > $out/intro

        # subpages
        for file in $out/subpages/*; do
          cp $file tmp; ${commands."${markupType}"} tmp > $file
        done
      '';
      content = let
          rawContent = readFile "${data}/content";
        in if rawContent == "" then {} else { content = rawContent; } ;
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
      content // intro // meta // subpages;

  /* Get data from a file
  */
  parseFile = { fileData, substitutions }@args:
    let
      # TODO make this regex stricter
      m    = match "^(....-..-..)-(.*)" fileData.basename;
      date = if m != null then { date = (elemAt m 0); } else {};
      path = "${fileData.dir + "/${fileData.name}"}";
      data =      if elem fileData.ext markupExts then parseMarkupFile args
             else if elem fileData.ext ext.nix    then import path
             else    abort "Error: this should never happen.";
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

  /* Get a list of files data from a directory
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
           else trace "Warning: File '${k}' is not in a supported file format and will be ignored." null
      ) (readDir from);
    in filter (x: x != null) fileList;

  markupToHtml = markup: text:
    let
      data = pkgs.runCommand "data" {} ''
        mkdir $out
        echo -n "${text}" > $out/source
        ${commands."${markup}"} $out/source > $out/content
      '';
    in readFile "${data}/content";

in
rec {

  /* load the data files from a directory that styx can handle
  */
  loadDir = { dir, substitutions ? {}, ... }@args:
    let extraArgs = removeAttrs args [ "dir" "substitutions" ];
    in
    map (fileData:
      (parseFile { inherit fileData substitutions; }) // extraArgs
    ) (getFiles dir);

  /* load a data file
  */
  loadFile = { dir, file, substitutions ? {}, ... }@args:
    let
      extraArgs = removeAttrs args [ "dir" "file" "substitutions" ];
      m = match "^(.*)\\.([^.]+)$" file;
      basename = elemAt m 0;
      ext = elemAt m 1;
      fileData = { inherit dir basename ext; name = file; };
    in
      (parseFile { inherit substitutions fileData; }) // extraArgs;

  /* Convert a markdown string to html
  */
  markdownToHtml = markupToHtml "markdown";

  /* Convert an asciidoc string to html
  */
  asciidocToHtml = markupToHtml "asciidoc";

  /* Generate a taxonomy data structure
  */
  mkTaxonomyData = { data, taxonomies }:
   let
     rawTaxonomy =
       fold (taxonomy: plist:
         fold (set: plist:
           fold (term: plist:
             plist ++ [ { "${taxonomy}" = [ { "${term}" = [ set ]; } ]; } ]
           ) plist set."${taxonomy}"
         ) plist (filter (d: hasAttr taxonomy d) data)
       ) [] taxonomies;
     semiCleanTaxonomy = propFlatten rawTaxonomy;
     cleanTaxonomy = map (pl:
       { "${propKey pl}" = propFlatten (propValue pl); }
     ) semiCleanTaxonomy;
   in cleanTaxonomy;

  /* sort terms by number of values
  */
  sortTerms = sort (a: b:
    valuesNb a > valuesNb b
  );

  /* Number of values a term holds
  */
  valuesNb = term: length (propValue term);

  /* Group a set of data in a property list with a function
  */
  groupBy = list: f:
    propFlatten (map (d: { "${f d}" = [ d ]; } ) list);

}
