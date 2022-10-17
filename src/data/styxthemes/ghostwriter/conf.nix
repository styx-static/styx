{lib}:
with lib.lib; {
  site = {
    title = mkOption {
      description = "Site title.";
      type = types.str;
      default = "Ghostwriter Blog";
    };
    description = mkOption {
      description = "Site description.";
      type = types.str;
      default = ''
        Ghostwriter blog description
      '';
    };
    copyright = mkOption {
      description = "Site copyright.";
      type = types.str;
      default = ''
        &copy; 2017. All rights reserved.
      '';
    };
  };

  social = {
    twitter = mkOption {
      description = "Twitter link";
      type = with types; nullOr string;
      default = null;
    };

    github = mkOption {
      description = "GitHub link";
      type = with types; nullOr string;
      default = null;
    };

    gitlab = mkOption {
      description = "GitHub link";
      type = with types; nullOr string;
      default = null;
    };

    stack-overflow = mkOption {
      description = "Stack overflow link";
      type = with types; nullOr string;
      default = null;
    };

    google-plus = mkOption {
      description = "Google plus link";
      type = with types; nullOr string;
      default = null;
    };

    linked-in = mkOption {
      description = "Linked in link";
      type = with types; nullOr string;
      default = null;
    };

    email = mkOption {
      description = "GitHub link";
      type = with types; nullOr string;
      default = null;
    };
  };

  itemsPerPage = mkOption {
    default = 3;
    description = "Number of posts per page.";
    type = types.int;
  };

  # defaults
  lib.jquery.enable = true;
  lib.font-awesome.enable = true;
  lib.googlefonts = ["Open Sans:300italic,400italic,600italic,700italic,400,600,700,300&subset=latin,cyrillic-ext,latin-ext,cyrillic"];
}
