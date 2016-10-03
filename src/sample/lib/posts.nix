# Posts functions

with import ./nixpkgs-lib.nix;
with builtins;

let
  # Extra packages to use
  extraPkgs = {
    markdown = pkgs.callPackage ({ stdenv, fetchzip }: stdenv.mkDerivation {
      name = "markdown-1.0.1";
      src = fetchzip {
        url = http://daringfireball.net/projects/downloads/Markdown_1.0.1.zip;
        sha256 = "1mic1v7cliz59h04pj1gw001wzh346aw3dvb266agj706bg79kdf";
      };
      phases = ["installPhase"];
      installPhase = ''
        mkdir -p $out/bin
        cp $src/Markdown.pl $out/bin/markdown
        sed -i '1s:/usr/bin/perl:${pkgs.perl}/bin/perl:' $out/bin/markdown
      '';
    }) {};
  };

  # Package set
  pkgs = (import (import ../nixpkgs-path.nix) {}) // extraPkgs;

  # Non exposed functions

  chunksOf = k:
    let f = ys: xs:
        if xs == []
           then ys
           else f (ys ++ [(take k xs)]) (drop k xs);
    in f [];

in
rec {

  /* Get all the posts from a directory as post attribute sets
  */
  getPosts = postsDir:
    filter (x: x != null)
           (map (parsePost postsDir)
                (attrNames (filterAttrs (_: v: v == "regular")
                           (readDir postsDir))));

  /* Parse a post file into a post attribute set.

     A post attribute set consist in the following attributes:

     - timestamp: timestamp part of the post filename
     - href: relative URL to the post
     - title: post title
     - id: name part of the post file name
     - html: post content in HTML format
  */
  parsePost = postsDir: filename:
    let
      result = match "(....-..-..)-(.*)\.md" filename;
      timestamp = elemAt result 0;
      id = elemAt result 1;
      path = "${postsDir}/${filename}";
      year = substring 0 4 timestamp;
      href = "posts/${timestamp}-${id}.html";
      html = pkgs.runCommand "${timestamp}.html" {} ''
        ${pkgs.markdown}/bin/markdown < ${path} > $out
      '';
      title = readFile (pkgs.runCommand "${timestamp}-${id}.title" {} ''
        ${pkgs.xidel}/bin/xidel ${html} -e "//h1[1]/node()" -q > $out
        echo -n `tr -d '\n' < $out` > $out
      '');
    in
      if result == null 
         then abort "Post (${filename}) not in correct form (YYYY-MM-DD-<id>.md)."
      else if title == ""
         then abort "Post (${filename}) does not include title (h1)."
      else {
        inherit timestamp href title id;
        html = readFile html;
      };

  /* Sort a list of posts chronologically
  */
  sortPosts = sort (a: b: lessThan b.timestamp a.timestamp);

  /* Group posts for index and archive pages
  */
  groupPosts = conf: posts: {
    index   = take conf.postsOnIndexPage posts;
    archive = if conf.postsPerArchivePage == null
              then [ (drop conf.postsOnIndexPage posts) ]
              else chunksOf conf.postsPerArchivePage (drop conf.postsOnIndexPage posts);
  };

}
