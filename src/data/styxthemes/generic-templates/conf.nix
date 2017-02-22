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

    highlightjs = {
      enable = mkEnableOption "highlightjs";
      version = mkOption {
        default = "9.9.0";
        description = "Selects highlightjs version to use.";
        type = types.string;
      };
      style = mkOption {
        default = "default";
        description = "Style used by highlight.js, for available styles see https://highlightjs.org/static/demo/.";
        example = "agate";
        type = types.string;
      };
      extraLanguages = mkOption {
        default = [];
        description = "Extra languages to highlight, for available languages see https://highlightjs.org/static/demo/.";
        example = [ "nix" ];
        type = with types; listOf str;
      };
    };

    googlefonts = mkOption {
      description = "Google Fonts to load, for available fonts see https://fonts.google.com/.";
      type = with types; listOf str;
      default = [];
      example = [ "Barrio" "Fjalla One" ];
    };

    mathjax = {
      enable = mkEnableOption "mathjax";
    };

  };

  site.title = mkOption {
    description = "Site title.";
    type = types.str;
    default = "Generic Templates";
  };

  html = {
    doctype = mkOption {
      description = "Doctype declaration to use.";
      type = types.enum [ "html5" "html4" "xhtml1" ];
      default = "html5";
    };

    lang = mkOption {
      description = "An ISO 639-1 language code to set to the `html` tag.";
      type = types.str;
      default = "en";
    };
  };

  services = {
    google-analytics.trackingID = mkOption {
      description = "Google analytics service tracker ID, Google analytics is disabled if set to null.";
      type = with types; nullOr str;
      default = null;
    };

    mixpanel.key = mkOption {
      description = "Mixpanel service key, Mixpanel service is disabled if set to null.";
      type = with types; nullOr str;
      default = null;
    };

    disqus.shortname = mkOption {
      description = "Disqus service shortname. See link:https://help.disqus.com/customer/portal/articles/466208-what-s-a-shortname-[What's a shortname?] page for details.";
      type = with types; nullOr str;
      default = null;
    };
  };

}
