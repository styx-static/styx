{ lib, templates, data, ... }:
lib.normalTemplate (page:

  /* required extra css
  */
  ''
  <style type="text/css">
  body {
    padding-top: 50px;
  }
  .starter-template {
    padding: 40px 15px;
    text-align: center;
  }
  </style>
  ''

  /* In a normal site the navbar should be in templates.partials.content-pre
  */
+ templates.bootstrap.navbar.default {
    inverted = true;
    brand = ''<a class="navbar-brand" href="#">Styx Generic Templates</a>'';
    extraClasses = [ "navbar-fixed-top" ];
    content = [
      (templates.bootstrap.navbar.nav {
        items = data.navbar;
        currentPage = page;
      })
    ];
  } 

+ ''
  <div class="container">
    <div class="starter-template">
      <h1>Bootstrap starter template</h1>
      <p class="lead">Use this document as a way to quickly start any new project.<br> All you get is this text and a mostly barebones HTML document.</p>
    </div>
  </div><!-- /.container -->
  ''
)
