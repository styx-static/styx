{ lib, templates, ... }:
lib.normalTemplate { 
  content = ''
    <h1>404: Page not found</h1>
    <p class="lead">Sorry, we've misplaced that URL or it's pointing to something that doesn't exist. ${templates.tag.ilink { to = "/"; content = "Head back home"; }} to try finding it again.</p>
  '';
  title = "404";
}
