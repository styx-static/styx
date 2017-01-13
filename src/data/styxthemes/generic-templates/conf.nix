{ lib }:
with lib;
{
  /* Javascript and CSS Libraries using CDN
  */
  lib = {

    # using https://www.bootstrapcdn.com/
    bootstrap = {
      enable = mkEnableOption "bootstrap";
      version = mkOption {
        default = "3.3.7";
        description = "Selects bootstrap version to use.";
        type = types.string;
      };
    };

    # using http://code.jquery.com/
    jquery = {
      enable = mkEnableOption "jQuery";
      version = mkOption {
        default = "3.1.1";
        description = "Selects jQuery version to use.";
        type = types.string;
      };
    };

    # font awesome
    font-awesome = {
      enable = mkEnableOption "font awesome";
      version = mkOption {
        default = "4.7.0";
        description = "Selects font-awesome version to use.";
        type = types.string;
      };
    };

  };

  site.title = mkOption {
    default = "Generic Templates";
    description = "String to append to the site `title` tag contents.";
    type = types.string;
  };

  html = {
    /* Choose the HTML doctype declaration
       
         html5 | html4 | xhtml1
    */
    doctype = mkOption {
      default = "html5";
      description = "Doctype declaration to use.";
      type = types.enum [ "html5" "html4" "xhtml1" ];
    };

    lang = "en";
  };

}
