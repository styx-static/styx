{ pkgs ? import <nixpkgs> {}
, renderDrafts ? false
, siteUrl ? null
, lastChange ? null
}@args:

let lib = import ./lib pkgs;
in with lib;

let


/* Basic setup

   This section is boilerplate code responsible for basic setup
*/

  /* Themes to use.
     Themes are defined in the conf.themesDir directory and provide templates
     and static files.
     Themes at the beginning of the list have higher priority.
  */
  themes = [ "default" ];

  /* Load the configuration
  */
  conf = overrideConf (import ./conf.nix) args;

  /* Set the state
     This is required to update the feed <updated> value.
  */
  state = { inherit lastChange; };

  /* Load templates from active themes
     templates are a set mimicking the themes template folder structure
     which value is the template function partially evaluated with the
     template environment.

     Example:

       {
         layout = TEMPLATE_FN;
         navbar = {
           main  = TEMPLATE_FN;
           brand = TEMPLATE_FN;
         }
       };
  */
  templates = lib.themes.loadTemplates {
    inherit themes defaultEnvironment customEnvironments;
    themesDir = conf.themesDir;
  };

  /* Load the static files from active themes
     return a list of static folders
  */
  files = lib.themes.loadFiles {
    inherit themes;
    themesDir = conf.themesDir;
  };


/* Templates

   This section declare template environments
   Extensions of template environments and their related code is declared here
*/

  /* Default template environment
     This should not require change
  */
  defaultEnvironment = { inherit conf state lib templates; };

  /* Defining a navbar for a custom template environment
     This Navbar contains the first archive page and the about page
  */
  navbar = [ (head pages.archives) pages.about ];

  /* Custom environments for specific templates
     customEnvironments is a set that mimic the templates set with the value
     being the template environment that the template will use.
     Any template not defined in this list will use the `defaultEnvironment`
  */
  customEnvironments = {
    # Adding navbar and feed variables to the layout template environment
    layout = defaultEnvironment // { inherit navbar; feed = pages.feed; };
  };


/* Pages

   This section declare the site pages
   Every page in this set will be generates
*/

  /* Pages attribute set
  */
  pages = rec {

    /* Index page
       Example of extending a page attribute set
    */
    index = {
      title = "Home";
      href = "index.html";
      template = templates.index;
      # Every attribute defined below is non standard
      inherit feed;
      posts = take conf.postsOnIndexPage posts;
      archivePage = head archives;
    };

    /* About page
       Example of importing content from a markdown file
    */
    about = {
      href = "about.html";
      template = templates.generic;
      # setting breadcrumbs
      breadcrumbs = [ index ];
    # importing a markdown files with the `parsePage` function
    } // (parsePage { dir = conf.pagesDir; file = "about.md"; });

    /* Post archives
       Example of splitting a page between a list of items
    */
    archives = splitPage {
      baseHref = "archives/posts";
      title = "Posts";
      template = templates.archive;
      items = posts;
      itemsPerPage = conf.postsPerArchivePage;
      breadcrumbs = [ index ];
    };

    /* RSS feed page
    */
    feed = {
      href = "feed.xml";
      template = templates.feed;
      # Showing only the last 10 posts in the feed
      posts = take 10 posts;
      # The feed page doesn't need a layout
      layout = id;
    };

    /* 404 error page
    */
    e404 = { href = "404.html"; template = templates.e404; title = "404"; };

    /* Posts pages (as a lit of page attribute sets)
       Fetch and sort the posts and drafts (only if renderDrafts is true) and set the
       template
    */
    posts = let
      # content substitutions
      substitutions = { inherit conf; };
      # fetching the posts
      posts = getPosts { inherit substitutions; from = conf.postsDir; to = "posts"; };
      # fetching the drafts
      drafts = optionals renderDrafts (getDrafts { inherit substitutions; from = conf.draftsDir; to = "drafts"; });
      # sort, set breadcrumbs and set a template
      preparePosts = p: p // { template = templates.post.full; breadcrumbs = with pages; [ index (head archives) ]; };
    in sortPosts (map preparePosts (posts ++ drafts));

  };

  /* Converts the page attribute set to a list of page suitable for
     `generateSite` function.
     This also sets the default layout.
  */
  pagesList =
    let list = (pagesToList pages);
    in map (setDefaultLayout templates.layout) list;


/* Site rendering

   This section render the site, for custom needs it is possible to use the `preGen` and `postGen` hooks
*/

in generateSite { inherit files pagesList; }
