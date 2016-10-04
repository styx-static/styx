{ previewMode ? false
, siteUrl ? null
, lastChange ? null
}@args:

let lib = import ./lib;
in with lib;

let

  # Load the configuration
  conf = extendConf (import ./conf.nix) args;

  # Set the state
  state = { inherit lastChange; };

  # Function to load a template with a generic environment
  loadTemplate = loadTemplateWithEnv { inherit conf state lib templates; };

  # List of templates
  templates = {
    base    = loadTemplate "base.nix";
    archive = loadTemplate "archive.nix";
    index   = loadTemplate "index.nix";
    atom    = loadTemplate "atom.nix";
    pagination = loadTemplate "pagination.nix";
    post = {
      full     = loadTemplate "post.full.nix";
      list     = loadTemplate "post.list.nix";
      atomList = loadTemplate "post.atom-list.nix";
    };
  };

  # Index page
  index = {
    href = "index.html";
    template = templates.index;
    posts = take conf.postsOnIndexPage posts;
    archivePage = head archives;
  };

  # Archive page using pagination
  archives = paginatePage {
    baseName = "archives/posts";
    template = templates.archive;
    items = posts;
    itemsPerPage = conf.postsPerArchivePage;
  };

  # RSS feed page
  feed = { posts = take 10 posts; href = "atom.xml"; template = templates.atom; };

  # List of posts
  # Fetch and sort the posts and drafts (only in preview mode) and set the
  # template
  posts = let
    posts = (getPosts conf.postsDir);
    drafts = optionals previewMode (getPosts conf.draftsDir);
  in sortPosts (map (setTemplate templates.post.full) (posts ++ drafts));

  # List of pages to generate
  pages = [ index feed ] ++ archives ++ posts;

in generateBasicSite { inherit conf pages; }
