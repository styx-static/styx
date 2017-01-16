{ lib, conf, ... }:
with lib;
''
<!-- Navigation -->
<nav class="navbar navbar-default navbar-fixed-top">
  <div class="container">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header page-scroll">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand page-scroll" href="#page-top">${conf.theme.site.title}</a>
    </div>
    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav navbar-right">
        <li class="hidden">
          <a href="#page-top"></a>
        </li>

          ${mapTemplate (menu: ''
          <li>
            <a href="${menu.url}">${menu.name}</a>
          </li>
          '') conf.theme.menu.prepend}

          ${optionalString (conf.theme.services.items != []) ''
          <li>
            <a class="page-scroll" href="#services">Services</a>
          </li>
          ''}

          ${optionalString (conf.theme.portfolio.items != []) ''
          <li>
            <a class="page-scroll" href="#portfolio">Portfolio</a>
          </li>
          ''}

          ${optionalString (conf.theme.about.items != []) ''
          <li>
            <a class="page-scroll" href="#about">About</a>
          </li>
          ''}

          ${optionalString (conf.theme.team.members != []) ''
          <li>
            <a class="page-scroll" href="#team">Team</a>
          </li>
          ''}

          ${optionalString (conf.theme.contact.enable) ''
          <li>
            <a class="page-scroll" href="#contact">Contact</a>
          </li>
          ''}

          ${mapTemplate (menu: ''
          <li>
            <a href="${menu.url}">${menu.name}</a>
          </li>
          '') conf.theme.menu.append}

      </ul>
    </div>
    <!-- /.navbar-collapse -->
  </div>
  <!-- /.container-fluid -->
</nav>
''
