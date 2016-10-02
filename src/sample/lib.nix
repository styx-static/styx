{ pkgs }:

with pkgs.lib;
with builtins;

let

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

  chunksOf = k:
    let
      f = ys: xs:
        if xs == []
          then ys
          else f (ys ++ [(take k xs)]) (drop k xs);
    in
      f [];

in

pkgs.lib // rec {

  ### Template functions

  prettyTimestamp = timestamp:
    let
      year = substring 0 4 timestamp;
      day = substring 8 2 timestamp;
      month' = substring 5 2 timestamp;
      month =
             if month' == "01" then "JAN"
        else if month' == "02" then "FEB"
        else if month' == "03" then "MAR"
        else if month' == "04" then "APR"
        else if month' == "05" then "MAY"
        else if month' == "06" then "JUN"
        else if month' == "07" then "JUL"
        else if month' == "08" then "AUG"
        else if month' == "09" then "SEP"
        else if month' == "10" then "OCT"
        else if month' == "11" then "NOV"
        else if month' == "12" then "DEC"
        else abort "Unknown month (${month'}) for date (${timestamp}).";
    in
      "${day} ${month} ${year}";

  /* concat strings with a new line
  */
  concat = concatMapStringsSep "\n";

  ### Template utilities

  /* Load a template with an environment set
  */
  loadTemplateWithEnv = env: file: import (env.conf.templatesDir + "/${file}") env;

  /* Attach a template to a page attribute set
  */
  setTemplate = template: page: page // { inherit template; };


  ## Configuration untilities

  /* Extend the conf attribute set with the override attribute set.
     Update is recursive and only keys with a non-null value are updated.
  */
  extendConf = conf: override:
    conf // (filterAttrs (_: v: v != null) override);


  ### Posts

  /* Get all the posts from a directory as post attribute sets
  */
  getPosts = postsDir:
    (filter (x: x != null)
           (map (parsePost postsDir)
                (attrNames (filterAttrs (_: v: v == "regular")
                           (readDir postsDir)))));

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
        ${markdown}/bin/markdown < ${path} > $out
      '';
      title = readFile (pkgs.runCommand "${timestamp}-${id}.title" {} ''
        ${pkgs.xidel}/bin/xidel ${html} -e "//h1[1]/node()" -q > $out
        echo -n `tr -d '\n' < $out` > $out
      '');
    in
      if result == null then
        abort "Post (${filename}) not in correct form (YYYY-MM-DD-<id>.md)."
      else if title == "" then
        abort "Post (${filename}) does not include title (h1)."
      else
        {
          inherit timestamp href title id;
          html = readFile html;
        };

  /* Sort a list of posts chronologically
  */
  sortPosts = sort (a: b: lessThan b.timestamp a.timestamp);

  /* Group posts for index and archive pages
  */
  groupPosts = conf: posts: {
    index = take conf.postsOnIndexPage posts;
    archive = if conf.postsPerArchivePage == null
              then [ (drop conf.postsOnIndexPage posts) ]
              else chunksOf conf.postsPerArchivePage (drop conf.postsOnIndexPage posts);
  };


  ### Site generation

  /* Generate the index page
  */
  generateIndex = template: groupedPosts: {
    inherit template;
    href = "index.html";
    nextPage = if length groupedPosts.archive > 1 then "archive-1.html" else null;
    posts = groupedPosts.index;
    prevPage = null;
  };

  /* Generate the archives pages
  */
  generateArchives = template: archivePosts:
    imap (i: posts: {
      inherit posts template;
      href = "archive-${toString i}.html";
      nextPage =
        if length archivePosts >= i + 1 then "archive-${toString (i + 1)}.html" else null;
      prevPage =
        if i == 1
          then "index.html"
          else "archive-${toString (i - 1)}.html";
    }) archivePosts;

  /* Generate the site
  */
  generateSite = {
    conf
  , pages
  , preInstall ? ""
  , postInstall ? ""
  }:
    pkgs.runCommand conf.siteId {} ''
      mkdir -p $out

      eval "${preInstall}"

      for file in ${conf.staticDir}/*; do
        ln -s $file $out/
      done

      ${concatMapStringsSep "\n" (page: ''
        mkdir -p `dirname $out/${page.href}`
        ln -s ${pkgs.writeText "${conf.siteId}-${replaceStrings ["/"] ["-"] page.href}" (page.template page) } $out/${page.href}
      '') pages}

      echo "${conf.siteUrl}" > $out/CNAME
      sed -i -e "s|https://||" $out/CNAME
      sed -i -e "s|http://||" $out/CNAME

      touch $out/.nojekyll

      eval "${postInstall}"
    '';
}
