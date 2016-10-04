# Posts functions
# TODO: post generation is quite slow, to improve

with import ./nixpkgs-lib.nix;
with builtins;

let
  # Package set
  pkgs = import ./pkgs.nix;
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
         then trace "Post (${filename}) is not in correct form (YYYY-MM-DD-<id>.md) and will be ignored." null
      else if title == ""
         then trace "Post (${filename}) does not include title (h1) and will be ignored." null
      else {
        inherit timestamp href title id;
        html = readFile html;
      };

  /* Sort a list of posts chronologically
  */
  sortPosts = sort (a: b: lessThan b.timestamp a.timestamp);

}
