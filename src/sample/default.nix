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
  loadTemplate = loadTemplateWithEnv genericEnv;

  # Generic template environment
  genericEnv = { inherit conf state lib templates; feed = feed; };

  # List of templates
  templates = {
    # layout template
    # Example of setting a custom template environment
    base    = loadTemplateWithEnv 
                (genericEnv // { navbar = [ about ]; })
                "base.nix";
    # index page template
    index   = loadTemplate "index.nix";
    # about page
    about   = loadTemplate "about.nix";
    # archive pages template
    archive = loadTemplate "archive.nix";
    # feed template
    feed    = loadTemplate "feed.nix";
    pagination = loadTemplate "pagination.nix";
    navbar = {
      main = loadTemplate "navbar.main.nix";
      brand = loadTemplate "navbar.brand.nix";
    };
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

  # About page
  about = {
    href = "about.html";
    template = templates.about;
    title = "About";
  };

  # Post archives pages gnerated by spliting the number of posts on multiple pages
  archives = splitPage {
    baseHref = "archives/posts";
    template = templates.archive;
    items = posts;
    itemsPerPage = conf.postsPerArchivePage;
  };

  # RSS feed page
  feed = { posts = take 10 posts; href = "feed.xml"; template = templates.feed; };

  # List of posts
  # Fetch and sort the posts and drafts (only in preview mode) and set the
  # template
  posts = let
    posts = (getPosts conf.postsDir);
    drafts = optionals previewMode (getPosts conf.draftsDir);
  in sortPosts (map (setTemplate templates.post.full) (posts ++ drafts));

  # List of pages to generate
  pages = [ index feed about ] ++ archives ++ posts;

in generateBasicSite { inherit conf pages; }
