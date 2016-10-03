{ currentTimestamp
, previewMode ? false
, siteUrl ? null
}@args:

let lib = import ./lib;
in with lib;

let

  # Load the configuration
  conf = extendConf (import ./conf.nix) args;

  # Set the state
  state = { inherit currentTimestamp; };

  # Function to load a template with a generic environment
  loadTemplate = loadTemplateWithEnv { inherit conf state lib templates; };

  # List of templates
  templates = {
    base    = loadTemplate "base.nix";
    archive = loadTemplate "archive.nix";
    index   = loadTemplate "index.nix";
    atom    = loadTemplate "atom.nix";
    post = {
      full     = loadTemplate "post.full.nix";
      list     = loadTemplate "post.list.nix";
      atomList = loadTemplate "post.atom-list.nix";
    };
  };

  # Group the posts between index and archive according to the configuration settings
  groupedPosts = groupPosts conf posts;

  # The index page, take the groupedPosts as a parameter
  index = generateIndex templates.index groupedPosts;

  # RSS feed page
  feed = { inherit posts; href = "atom.xml"; template = templates.atom; };

  # Archive page, only generated if the number of posts is greater than conf.postsOnIndexPage
  archives = generateArchives templates.archive groupedPosts;

  # List of posts
  # Fetch and sort the posts and drafts (only in preview mode) and set the template
  posts = let
    posts = (getPosts conf.postsDir);
    drafts = optionals previewMode (getPosts conf.draftsDir);
  in sortPosts (map (setTemplate templates.post.full) (posts ++ drafts));

  # List of pages to generate
  pages = [ index feed ] ++ archives ++ posts;

in generateBasicSite { inherit conf pages; }
