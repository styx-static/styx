{

themes.agency = {
  
  site = {
    title = "The Agency";
    author = "Your name";
    description = "Your description";
  };

  menu.prepend = [
  ];

  menu.append = [
    { url  = "https://styx-static.github.io/styx-site/";
      name = "Styx"; }
  ];

  hero = {
    title = "Welcome To Our Studio!";
    subtitle = "It's nice to meet you";
    buttonText = "Tell me more"; };

  services = {
    title = "Services";
    subtitle = "Lorem ipsum dolor sit amet consectetur.";
  };

  portfolio = {
    title = "Portfolio";
    subtitle = "Lorem ipsum dolor sit amet consectetur."; };

  about = {
    title = "About";
    subtitle = "Lorem ipsum dolor sit amet consectetur.";
    endpoint = "Be part<br>of our<br>story!";
  };

  team = {
    title = "Our amazing team";
    subtitle = "Lorem ipsum dolor sit amet consectetur.";
    description = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Aut eaque, laboriosam veritatis, quos non quis ad perspiciatis, totam corporis ea, alias ut unde.";
  };

  contact = {
    title = "Contact us";
    subtitle  = "Lorem ipsum dolor sit amet consectetur.";
    buttonText = "Send message";
    form = {
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

  footer = {
    copyright = "Published under the Apache License 2.0.";
    social = [
      { icon = "fa-twitter"; link ="#"; }
      { icon = "fa-facebook"; link ="#"; }
      { icon = "fa-linkedin"; link ="#"; }
    ];
    quicklinks = [
      { text = "Privacy Policy"; link ="#"; }
      { text = "Terms of Use"; link ="#"; }
    ];
  };

};

}
