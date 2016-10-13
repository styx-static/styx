# Data functions

lib: pkgs:
with lib;

let

  /* The supported content types
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

        mkdir $out

        # fetching metablock
        if [ "$(sed -n "$metaBlock" < ${path})" ]; then
          echo "{" > $out/meta
          sed -n "$metaBlock" < ${path} | sed '1d;$d' >> $out/meta
          echo "}" >> $out/meta
          sed "1,`sed -n "$metaBlock" < ${path} | wc -l`d" < ${path} > $out/source
        else
          echo "{}" > $out/meta
          cp ${path} $out/source
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
        ${if (elem fileData.ext markdownExt) then '' 
          ${pkgs.multimarkdown}/bin/multimarkdown < $out/source > $out/content
          ${pkgs.xidel}/bin/xidel $out/content -e "//h1[1]/node()" -q > $out/title
          echo -n `tr -d '\n' < $out/title` > $out/title
          '' else ''
          touch $out/content
          touch $out/title
        ''}
      '';
      content = let
          rawContent = readFile "${data}/content";
        in if rawContent == "" then {} else { content = rawContent; } ;
      title = let
          rawContent = readFile "${data}/title";
        in if rawContent == "" then {} else { title = rawContent; };
      meta = import   "${data}/meta";
    in
      content // title // meta;

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

  /* Get a list of data files from a folder
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

  /* Sort a list of posts chronologically
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
