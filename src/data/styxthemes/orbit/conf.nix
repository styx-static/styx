{ lib }:
with lib;
{
/* General settings
*/
  site = {
    title = mkOption {
      default = "Orbit theme";
      type = types.str;
      description = "Title of the site.";
    };
    author = mkOption {
      default = "John Doe";
      type = types.str;
      description = "Content of the author `meta` tag.";
    };
    description = mkOption {
      default = "Lorem ipsum...";
      type = types.str;
      description = "Content of the description `meta` tag.";
    };
  };

  colorScheme = mkOption {
    default = 1;
    type = types.enum [ 1 2 3 4 5 6 ];
    description = "Theme color scheme.";
  };

  copyright = mkOption {
    default = "copyright";
    type = types.str;
    description = "Footer copyright text.";
  };

  profile = mkOption {
    description = "Profile information, must have `name`, `tagline` and `image` attributes.";
    type = types.attrs;
    default = {
      name    = "John Doe";
      tagline = "Full Stack Developer";
      image   = "profile.png";
    };
  };

/* Main contents
*/

  summary = {
    title = mkOption {
      description = "Title of the summary section";
      default = "Career profile";
      type = types.str;
    };
    icon = mkOption {
      description = "Code of the font awesome icon of the summary title.";
      default = "user";
      type = types.str;
    };
    content = mkOption {
      description = ''
        content of the profile area as HTML text.  
        if set to `null`, the summary area will not be displayed.
      '';
      default = null;
      type = with types; nullOr str;
    };
  };
/* Experiences
*/
  experiences = {
    title = mkOption {
      description = "Title of the experiences section";
      default = "Experiences";
      type = types.str;
    };
    icon = mkOption {
      description = "Code of the font awesome icon of the experience title.";
      default = "briefcase";
      type = types.str;
    };
    items = mkOption {
      description = ''
        List of experiences as attribute sets, requires `position`, `dates`, `company` and `content`.  
        If set to the empty list `[]`, the experiences area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
      example = [ {
        position = "Lead Developer";
        dates    = "2015 - Present";
        company  = "Startup Hubs, San Francisco";
        content  = "lorem ipsum";
      } ];
    };
  };

/* Projects
*/
  projects = {
    title = mkOption {
      description = "Title of the projects section";
      default = "Projects";
      type = types.str;
    };
    icon = mkOption {
      description = "Code of the font awesome icon of the projects title.";
      default = "archive";
      type = types.str;
    };
    items = mkOption {
      description = ''
        List of projects as attribute sets, requires `title`, `url` and `content`.  
        If set to the empty list `[]`, the projects area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
      example = [ {
        title = "Simple FAQ Theme for Hugo";
        url   = "https://github.com/aerohub/hugo-faq-theme";
        content  = "lorem ipsum";
      } ];
    };
  };


/* Skills
   
*/
  skills = {
    title = mkOption {
      description = "Title of the skills section.";
      default = "Skills & Proficiency";
      type = types.str;
    };
    icon = mkOption {
      description = "Code of the font awesome icon of the skills title.";
      default = "rocket";
      type = types.str;
    };
    items = mkOption {
      description = ''
        List of skills as attribute sets, requires `title` and `level`.  
        If set to the empty list `[]`, the skills area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
      example = [
        { skill = "Python & Django";
          level = "98%"; }
        { skill = "Javascript & jQuery";
          level = "50%"; }
      ];
    };
  };

/* Sidebar contents
*/

  contact.items = {
    items = mkOption {
      description = ''
        List of contact link as attribute sets, requires `type`, `icon`, `url` and `title`.  
        If set to the empty list `[]`, the skills area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
      example = [ {
        type  = "email";
        icon  = "envelope";
        url   = "mailto: yourname@email.com";
        title = "john.doe@website.com";
      } ];
    };
  };

  education = {
    title = mkOption {
      description = "Title of the education section.";
      default = "Education";
      type = types.str;
    };
    items = mkOption {
      description = ''
        List of education items as attribute sets, requires `degree`, `college` and `dates`.  
        If set to the empty list `[]`, the education area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
      example = [
        { degree  = "MSc in Computer Science";
          college = "University of London";
          dates   = "2006 - 2010"; }
      ];
    };
  };

  languages = {
    title = mkOption {
      description = "Title of the languages section.";
      default = "Languages";
      type = types.str;
    };
    items = mkOption {
      description = ''
        List of languages as attribute sets, requires `language`, and `level`.  
        If set to the empty list `[]`, the languages area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
      example = [
        { language = "English";
          level    = "Native"; }
      ];
    };
  };

  interests = {
    title = mkOption {
      description = "Title of the interests section.";
      default = "Interests";
      type = types.str;
    };
    items = mkOption {
      description = ''
        List of interests. If set to the empty list `[]`, the interests area will not be displayed.
      '';
      type = with types; listOf str;
      default = [];
      example = [
        "Climbing"
        "Snowboarding"
        "Cooking"
      ];
    };
  };

}
