{ lib }:
with lib;
{
  site = {
    description = mkOption {
      description = "Site description, added in the footer.";
      default = "Write a description for your new site here.";
      type = types.string;
    };

    copyright = mkOption {
      default = "&copy; 2017";
      type = types.string;
      description = "Site copyright, added in the footer.";
    };
  };

  index.itemsPerPage = mkOption {
    default = 4;
    description = "Number of posts on the index page.";
    type = types.int;
  };

  archives.itemsPerPage = mkOption {
    default = 15;
    description = "Number of posts on the archive page.";
    type = types.int;
  };
}
