# Content functions
# TODO: post generation is quite slow, to improve

lib: pkgs:
with lib;

let

  /* Get data from a markdown file
  */
  getFileData = path:
    let
      data = pkgs.runCommand "data" {} ''
        mkdir $out
        matterBlock="/{---/,/---}/p"
        if [ "$(sed -n "$matterBlock" < ${path})" ]; then
          sed -n "$matterBlock" < ${path} | sed '1d;$d' > $out/matter
          sed "1,`sed -n "$matterBlock" < ${path} | wc -l`d" < ${path} > $out/source
        else
          echo "{}" > $out/matter
          cp ${path} $out/source
        fi
        ${pkgs.multimarkdown}/bin/multimarkdown < $out/source > $out/content
        ${pkgs.xidel}/bin/xidel $out/content -e "//h1[1]/node()" -q > $out/title
        echo -n `tr -d '\n' < $out/title` > $out/title
      '';
      content = readFile "${data}/content";
      title   = readFile "${data}/title";
      matter  = import   "${data}/matter";
    in
      { inherit content title; } // matter;

in
rec {

  /* Similar to getPosts but add a `isDraft = true` attribute to all the posts
  */
  getDrafts = draftsDir: outDir:
    let
      drafts = getPosts draftsDir outDir;
    in map (d: d // { isDraft = true; }) drafts;

  /* Get all the posts from a directory as post attribute sets
  */
  getPosts = postsDir: outDir:
    filter (x: x != null)
           (map (parsePost postsDir outDir)
                (attrNames (filterAttrs (_: v: v == "regular")
                           (readDir postsDir))));

  /* Parse a markdown file to a partial page attribute set

     Returns an attribute set with the following attribute:

     - content: page content in HTML format
     - title: page title (first H1 content)
  */
  parsePage = pageDir: filename:
    getFileData "${pageDir + "/${filename}"}";

  /* Parse a post file into a post attribute set.

     A post attribute set consist in the following attributes:

     - timestamp: timestamp part of the post filename
     - href: relative URL to the post
     - title: post title
     - id: name part of the post file name
     - content: post content in HTML format
  */
  parsePost = postDir: outDir: filename:
    let
      result = match "^(....-..-..)-(.*)\.md$" filename;
      timestamp = elemAt result 0;
      id = elemAt result 1;
      path = "${postDir + "/${filename}"}";
      href = "${outDir}/${timestamp}-${id}.html";
      data = getFileData path;
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
