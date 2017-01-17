{ lib }:
with lib;
{
  # URL of the site, must be set to the url of the domain the site will be deployed
  siteUrl = "https://styx-static.github.io/styx-theme-orbit";

  # Theme settings
  theme = {
  
    /* General settings
    */
    site = {
      title = "Orbit Theme";
      description = "Lorem ipsum...";
      author = "John Doe";
    };
  
    colorScheme = 1;
  
    copyright = "copyright";
  
    profile = {
      name    = "John Doe";
      tagline = "Full Stack Developer";
      image   = "profile.png";
    };
  
  
    /* Experiences
    */
    experiences = {
      items = sortBy "index" "asc" (loadDir { dir = ./data/experiences; }); 
    };
  
    /* Projects
    */
    projects = {
      title = "Projects";
      icon  = "archive";
      items = sortBy "index" "asc" (loadDir { dir = ./data/projects; }); 
    };
  
    /* Skills
    */
    skills = {
      title = "Skills & Proficiency";
      icon  = "rocket";
      items = [
        { skill = "Python & Django";
          level = "98%"; }
        { skill = "Javascript & jQuery";
          level = "50%"; }
      ];
    };

    /* Summary
    */
    summary = {
      icon    = "user";
      title   = "Career Profile";
      content = (loadFile { dir = ./data; file = "summary.md"; }).content;
    };
  
    /* Sidebar contents
    */
  
    contact.items = [
      { type  = "email";
        icon  = "envelope";
        url   = "mailto: yourname@email.com";
        title = "john.doe@website.com"; } 
      { type  = "phone";
        icon  = "phone";
        url   = "tel:+1234567890";
        title = "+1234567890"; } 
      { type  = "website";
        icon  = "globe";
        url   = "http://portfoliosite.com";
        title = "portfoliosite.com"; } 
      { type  = "linkedin";
        icon  = "linkedin";
        url   = "http://linkedin.com/in/johndoe";
        title = "linkedin.com/in/johndoe"; } 
    ];
  
    education = {
      title = "Education";
      items = [
        { degree  = "MSc in Computer Science";
          college = "University of London";
          dates   = "2006 - 2010"; }
      ];
    };
  
    languages = {
      title = "Languages";
      items = [
        { language = "English";
          level    = "Native"; }
        { language = "French";
          level    = "Professional"; }
        { language = "Japanese";
          level    = "Fluent"; }
      ];
    };
  
    interests = {
      title = "Interests";
      items = [
        "Climbing"
        "Snowboarding"
        "Cooking"
        "Painting"
      ];
    };
  
  };

}
