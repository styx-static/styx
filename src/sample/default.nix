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
  genericEnv = { inherit conf state lib templates; feed = pages.feed; };

  # List of pages to include in the navbar
  # This is an example on how to extend a page attribute set
  navbar = let
             archive = (head pages.archives) // { title = "Archives"; };
           in [ archive pages.about ];

  # List of templates
  templates = {
    # layout template
    # Example of setting a custom template environment
    base    = loadTemplateWithEnv 
                (genericEnv // { inherit navbar; })
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

  # Pages attribute set
  pages = rec {

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
      drafts = optionals previewMode (getDrafts conf.draftsDir);
    in sortPosts (map (setTemplate templates.post.full) (posts ++ drafts));

  };

  # Convert the `pages` attribute set to a list
  # Can also be done manually with [ pages.index ... ]
  pageList = pagesToList pages;

in generateBasicSite { inherit conf; pages = pageList; }
