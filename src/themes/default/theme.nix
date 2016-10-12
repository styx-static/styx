/* Example configuration for the default theme
   
   This settings can be overriden in the main conf.nix
*/

{
  themes.default = {
    site = {
      # Site title, used in the site header and the atom feed
      title = "Styx Default Theme";

      # Site description used in the base template
      description = "Write a description for your new site here.";
    };
  
    # Number of posts on the index / archive page
    index.itemsPerPage = 5;
  };
}
