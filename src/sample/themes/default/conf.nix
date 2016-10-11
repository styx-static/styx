/* Example configuration for the default theme
   
   This settings can be changed in the main conf.nix
*/
let 

data = {

  site = {

    # Site title, used in the site header and the atom feed
    title = "Styx Default Theme";

    # Site description used in the base template
    description = "Write a description for your new site here.";

  };

  # Maximum number of posts on the index page
  index.numberOfPosts = 3;

  # Maximum number of posts per archive page
  archive.postsPerPage = 5;

};

in { themes.default = data; }
