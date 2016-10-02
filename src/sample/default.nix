{ pkgs ? import <nixpkgs> {}
, currentTimestamp
, previewMode ? false
, siteUrl ? null
}@args:

let lib = import ./lib.nix { inherit pkgs; };
  in with lib;

let

  # global configuration
  conf = extendConf (import ./conf.nix) args;

  # state
  state = { inherit currentTimestamp; };

  /* Loads a template with a generic environment
  */
  loadTemplate = loadTemplateWithEnv { inherit conf state lib templates; };

  # list of used templates
  templates = {
    base = loadTemplate "base.nix";
    archive = loadTemplate "archive.nix";
    index = loadTemplate "index.nix";
    mailchimp = loadTemplate "mailchimp.nix";
    atom = loadTemplate "atom.nix";
    post.full = loadTemplate "post.full.nix";
    post.list = loadTemplate "post.list.nix";
    post.atomList = loadTemplate "post.atom-list.nix";
  };

  # posts
  posts = let
    posts = (getPosts conf.postsDir);
    drafts = optionals previewMode (getPosts conf.draftsDir);
    template = templates.post.full;
  in sortPosts (map (setTemplate template) (posts ++ drafts));

  /* List of pages to generate, pages are attribute sets that should have at
     least the following attributes:

     - href: the path of the page, absolute to the site root
     - template: a template that evaluate the page attribute set and return
       the page HTML
  */
  pages = let
    # group post according to settings
    groupedPosts = groupPosts conf posts;
    index = generateIndex templates.index groupedPosts;
    archives = generateArchives templates.archive groupedPosts.archive;
    feed = { inherit posts; href = "atom.xml"; template = templates.atom; };
  in
   [ index feed ] ++ archives ++ posts;

in generateSite { inherit conf pages; }
