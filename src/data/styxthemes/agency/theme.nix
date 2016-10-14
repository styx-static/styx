{
  
/* General settings
*/
  site = {
    title = "The Agency";
    author = "Your name";
    description = "Your description";
  };

/* Navigation

  navigation items are set in the format

  {
    url = "LINK";
    name = "MENU NAME";
  }
*/

  # items to append to the main menu
  menu.prepend = [
    #{ url  = "https://styx-static.github.io/styx-site/";
    #  name = "Styx"; }
  ];

  # items to append to the main menu
  menu.append = [
    { url  = "https://styx-static.github.io/styx-site/";
      name = "Styx"; }
  ];

/* Main sections

   Any section declared here can be disabled by setting it to null

   Example:
   
     services = null;

   Data centric sections (services, portfolio, about and team) will not be displayed if no data is available.
*/

/* Main banner
*/
  hero = {
    title = "Welcome To Our Studio!";
    subtitle = "It's nice to meet you";
    buttonText = "Tell me more"; };

/* Services
   
   Service data is managed in markdown files in the data/services directory
*/
  services = {
    title = "Services";
    subtitle = "Lorem ipsum dolor sit amet consectetur.";
  };

/* Portfolio

   Portfolio data is managed in markdown files in the data/projects directory
*/

  portfolio = {
    title = "Portfolio";
    subtitle = "Lorem ipsum dolor sit amet consectetur."; };

/* About

   About data is managed in markdown files in the data/events directory
*/
  about = {
    title = "About";
    subtitle = "Lorem ipsum dolor sit amet consectetur.";
    endpoint = "Be part<br>of our<br>story!";
  };

/* Team

   Team data is managed in the data/team.nix file
*/
  team = {
    title = "Our amazing team";
    subtitle = "Lorem ipsum dolor sit amet consectetur.";
    description = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Aut eaque, laboriosam veritatis, quos non quis ad perspiciatis, totam corporis ea, alias ut unde.";
  };

/* Contact form
 
   The contact form is meant to be used with formspree.io
*/
  contact = {
    title = "Contact us";
    subtitle  = "Lorem ipsum dolor sit amet consectetur.";
    buttonText = "Send message";
    form = {
      # Set the contact form receiver here
      receiver = "your@email.com";
      name = {
        text = "Your Name *";
        warning = "Please enter your name.";
      };
      email = {
        text = "Your Email *";
        warning = "Please enter your email address.";
      };
      phone = {
        text = "Your Phone *";
        warning = "Please enter your phone number.";
      };
      message = {
        text = "Your Message *";
        warning = "Please enter a message.";
      };
    };
  };

/* Footer

   This section control the links and copyright in the footer
*/
  footer = {
    copyright = "Published under the Apache License 2.0.";
    social = [
      { icon = "fa-twitter";  link ="#"; }
      { icon = "fa-facebook"; link ="#"; }
      { icon = "fa-linkedin"; link ="#"; }
    ];
    quicklinks = [
      { text = "Privacy Policy"; link ="#"; }
      { text = "Terms of Use";   link ="#"; }
    ];
  };

}
