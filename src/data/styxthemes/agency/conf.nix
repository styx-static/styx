{ lib }:
with lib;
{
  
/* General settings
*/
  site = {
    title = mkOption {
      default = "The Agency";
      type = types.str;
      description = "Title of the site.";
    };
    author = mkOption {
      default = "Your name";
      type = types.str;
      description = "Content of the author `meta` tag.";
    };
    description = mkOption {
      default = "Your description";
      type = types.str;
      description = "Content of the description `meta` tag.";
    };
  };

/* Navigation
*/

  menu = {
    prepend = mkOption {
      default = [];
      type = with types; listOf attrs;
      example = [
        { url  = "https://styx-static.github.io/styx-site/";
          name = "Styx"; }
      ];
      description = "Menu items to add at the beginning of the navigation.";
    };
    append = mkOption {
      default = [];
      type = with types; listOf attrs;
      example = [
        { url  = "https://styx-static.github.io/styx-site/";
          name = "Styx"; }
      ];
      description = "Menu items to add at the end of the navigation.";
    };
  };

/* Main banner
*/
  hero = {
    title = mkOption {
      default = "Welcome To Our Studio!";
      type = types.str;
      description = "Title of the hero area.";
    };
    subtitle = mkOption {
      default = "It's nice to meet you";
      type = types.str;
      description = "Subtitle of the hero area.";
    };
    buttonText = mkOption {
      default = "Tell me more";
      type = types.str;
      description = "Button text of the hero area.";
    };
  };

/* Services
*/
  services = {
    title    = mkOption {
      default = "Services";
      description = "Title of the services area.";
      type = types.str;
    };
    subtitle = mkOption {
      default = "Lorem ipsum dolor sit amet consectetur.";
      description = "Subtitle of the services area.";
      type = types.str;
    };
    items = mkOption {
      example = [{
        icon = "fa-shopping-cart";
        title = "E-Commerce";
        content = "Lorem ipsum dolor sit amet consectetur.";
      }];
      description = ''
        List of services as attribute sets, requires `title`, `icon` and `content` attributes.  
        If set to the empty list `[]`, the services area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
    };
  };

/* Portfolio
*/

  portfolio = {
    title    = mkOption {
      default = "Services";
      description = "Title of the portfolio area.";
      type = types.str;
    };
    subtitle = mkOption {
      default = "Lorem ipsum dolor sit amet consectetur.";
      description = "Subtitle of the portolio area.";
      type = types.str;
    };
    items = mkOption {
      example = [ {
        title = "Round Icons";
        subtitle = "Lorem ipsum dolor sit amet consectetur.";
        date = "2014-07-05";
        img = "roundicons.png";
        preview = "roundicons-preview.png";
        client = "Start Bootstrap";
        clientLink = "#";
        category = "Graphic Design";
        content = "Lorem ipsum dolor sit amet consectetur.";
      }];
      description = ''
        List of portfolio projects as attribute sets, requires `title`, `subtitle`, `img`, `preview`, `client`, `clientLink`, `category` and `content`.  
        If set to the empty list `[]`, the portfolio area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
    };
  };

/* About
*/
  about = {
    title    = mkOption {
      default = "About";
      description = "Title of the about area.";
      type = types.str;
    };
    subtitle = mkOption {
      default = "Lorem ipsum dolor sit amet consectetur.";
      description = "Subtitle of the about area.";
      type = types.str;
    };
    items = mkOption {
      example = [{
        img     = "1.jpg";
        date    = "2009-2011";
        title   = "Our Humble Beginnings";
        content = "Lorem ipsum dolor sit amet consectetur.";
      }];
      description = ''
        List of about events as attribute sets, requires `img`, `date`, `title`, and `content`.  
        If set to the empty list `[]`, the about area will not be displayed.
      '';
      type = with types; listOf attrs;
      default = [];
    };
    endpoint = mkOption {
      default = "Be part<br>of our<br>story!";
      description = "Last about bubble text.";
      type = types.str;
    };
  };

/* Team
*/
  team = {
    title    = mkOption {
      default = "About";
      description = "Title of the team area.";
      type = types.str;
    };
    subtitle = mkOption {
      default = "Lorem ipsum dolor sit amet consectetur.";
      description = "Subtitle of the team area.";
      type = types.str;
    };
    members = mkOption {
      example = [{
        img = "1.jpg";
        name = "Kay Garland";
        position = "Lead Designer";
        social = [
          { type = "twitter"; link = "#"; }
          { type = "facebook"; link = "#"; }
          { type = "linkedin"; link = "#"; }
        ];
      }];
      description = ''
        List of team members as attribute sets, requires `img`, `name`, `position`, and `social`. `social` have the same format to `footer.social`.
        If set to the empty list `[]`, the team area will not be displayed.";
      '';
      type = with types; listOf attrs;
      default = [];
    };
    description = mkOption {
      default = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Aut eaque, laboriosam veritatis, quos non quis ad perspiciatis, totam corporis ea, alias ut unde.";
      description = "Description of the team";
      type = types.str;
    };
  };

/* Clients
*/
  clients = mkOption {
    example = [
      { logo = "envato.jpg"; link = "#"; }
      { logo = "designmodo.jpg"; link = "#"; }
    ];
    description = ''
      List of clients as attribute sets, requires `logo` and `link`.  
      If set to the empty list `[]`, the clients area will not be displayed.";
    '';
    type = with types; listOf attrs;
    default = [];
  };

/* Contact form
*/
  contact = {
    enable = mkEnableOption "contact area";
    title = mkOption {
      default = "Lorem ipsum dolor sit amet consectetur.";
      description = "Title of the contact area.";
      type = types.str;
    };
    subtitle = mkOption {
      default = "Lorem ipsum dolor sit amet consectetur.";
      description = "Subtitle of the contact area.";
      type = types.str;
    };
    buttonText = mkOption {
      default = "Send message";
      description = "Text of the contact area button.";
      type = types.str;
    };
    form = {
      receiver = mkOption {
        description = "Contact area from receiver mail address.";
        default = "your@email.com";
        type = types.str;
      };
      name = mkOption {
        description = "Contact form name input label";
        type = types.attrs;
        default = {
          text = "Your Name *";
          warning = "Please enter your name.";
        };
      };
      email = mkOption {
        description = "Contact form email input label";
        type = types.attrs;
        default = {
          text = "Your Email *";
          warning = "Please enter your email address.";
        };
      };
      phone = mkOption {
        description = "Contact form phone input label";
        type = types.attrs;
        default = {
          text = "Your Phone *";
          warning = "Please enter your phone number.";
        };
      };
      message = mkOption {
        description = "Contact form message input label";
        type = types.attrs;
        default = {
          text = "Your Message *";
          warning = "Please enter a message.";
        };
      };
    };
  };

/* Footer

   This section control the links and copyright in the footer
*/
  footer = {
    copyright = mkOption {
      default = "Published under the Apache License 2.0.";
      description = "Footer copyright text.";
      type = types.str;
    };
    social = mkOption {
      description = "Social media links to display in the footer.";
      type = with types; listOf attrs;
      default = [];
      example = [
        { icon = "fa-twitter";  link ="#"; }
        { icon = "fa-facebook"; link ="#"; }
        { icon = "fa-linkedin"; link ="#"; }
      ];
    };
    quicklinks = mkOption {
      description = "Footer links.";
      type = with types; listOf attrs;
      default = [];
      example = [
        { text = "Privacy Policy"; link ="#"; }
        { text = "Terms of Use";   link ="#"; }
      ];
    };
  };

}
