# Posts functions
# TODO: post generation is quite slow, to improve

lib: pkgs:
with lib;

rec {

  /* Similar to getPosts but add a `isDraft = true` attribute to all the posts
  */
  getDrafts = draftDir: outDir:
    let
      drafts = getPosts draftDir outDir;
    in map (d: d // { isDraft = true; }) drafts;

  /* Get all the posts from a directory as post attribute sets
  */
  getPosts = postsDir: outDir:
    filter (x: x != null)
           (map (parsePost postsDir outDir)
                (attrNames (filterAttrs (_: v: v == "regular")
                           (readDir postsDir))));

  /* Parse a post file into a post attribute set.

     A post attribute set consist in the following attributes:

     - timestamp: timestamp part of the post filename
     - href: relative URL to the post
     - title: post title
     - id: name part of the post file name
     - content: post content in HTML format
  */
  parsePost = postsDir: outDir: filename:
    let
      result = match "^(....-..-..)-(.*)\.md$" filename;
      timestamp = elemAt result 0;
      id = elemAt result 1;
      path = "${postsDir + "/${filename}"}";
      href = "${outDir}/${timestamp}-${id}.html";
      data = pkgs.runCommand "${timestamp}-data" {} ''
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
      if result == null 
         then trace "Post (${filename}) is not in correct form (YYYY-MM-DD-<id>.md) and will be ignored." null
      else if title == ""
         then trace "Post (${filename}) does not include title (h1) and will be ignored." null
      else {
        inherit timestamp href title id content;
      } // { inherit matter; };

  /* Sort a list of posts chronologically
  */
  sortPosts = sort (a: b: lessThan b.timestamp a.timestamp);

}
