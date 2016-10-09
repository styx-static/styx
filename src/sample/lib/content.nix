# Content functions
# TODO: post generation is quite slow, to improve

lib: pkgs:
with lib;

let

  /* Get data from a markdown file
  */
  getFileData = substitutions: path:
    let
      data = pkgs.runCommand "data" {} ''
        mkdir $out
        metaBlock="/{---/,/---}/p"
        if [ "$(sed -n "$metaBlock" < ${path})" ]; then
          sed -n "$metaBlock" < ${path} | sed '1d;$d' > $out/meta
          sed "1,`sed -n "$metaBlock" < ${path} | wc -l`d" < ${path} > $out/source
        else
          echo "{}" > $out/meta
          cp ${path} $out/source
        fi
        ${concatMapStringsSep "\n" (set:
          let
            key = head (attrNames set);
            value = head (attrValues set);
          in
            ''
              substituteInPlace $out/source \
                --subst-var-by ${key} ${value}
            ''
        ) (setToList substitutions)}
        ${pkgs.multimarkdown}/bin/multimarkdown < $out/source > $out/content
        ${pkgs.xidel}/bin/xidel $out/content -e "//h1[1]/node()" -q > $out/title
        echo -n `tr -d '\n' < $out/title` > $out/title
      '';
      content = readFile "${data}/content";
      title   = readFile "${data}/title";
      meta    = import   "${data}/meta";
    in
      { inherit content title; } // meta;

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

in
rec {

  /* Similar to getPosts but add a `isDraft = true` attribute to all the posts
  */
  getDrafts = args:
    map (d: d // { isDraft = true; }) (getPosts args);

  /* Get all the posts from a directory as post attribute sets
  */
  getPosts = { from, ... }@args:
    filter (x: x != null)
           (map (parsePost args)
                (attrNames (filterAttrs (_: v: v == "regular")
                           (readDir from))));

  /* Parse a markdown file to a partial page attribute set

     Returns an attribute set with the following attribute:

     - content: page content in HTML format
     - title: page title (first H1 content)
  */
  parsePage = { dir, file, substitutions ? {} }:
    getFileData substitutions "${dir + "/${file}"}";

  /* Parse a post file into a post attribute set.

     A post attribute set consist in the following attributes:

     - timestamp: timestamp part of the post filename
     - href: relative URL to the post
     - title: post title
     - id: name part of the post file name
     - content: post content in HTML format
  */
  parsePost = { from, to, substitutions ? {} }@args: filename:
    let
      result = match "^(....-..-..)-(.*)\.md$" filename;
      timestamp = elemAt result 0;
      id = elemAt result 1;
      path = "${from + "/${filename}"}";
      href = "${to}/${timestamp}-${id}.html";
      data = getFileData substitutions path;
    in
      if result == null 
         then trace "Post (${filename}) is not in correct form (YYYY-MM-DD-<id>.md) and will be ignored." null
      else {
        inherit timestamp href id;
      } // data;

  /* Sort a list of posts chronologically
  */
  sortPosts = sort (a: b: lessThan b.timestamp a.timestamp);

}
