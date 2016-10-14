{ conf, lib, data, ... }:
with lib;
''
<div class="sidebar">
  <div class="container sidebar-sticky">
    <div class="sidebar-about">
      <a href="${conf.siteUrl}"><h1>${conf.theme.site.title}</h1></a>
      <p class="lead">
      ${if (conf.theme.site ? description) then conf.theme.site.description else ''
        An elegant open source and mobile first theme for styx made by <a href="http://twitter.com/mdo">@mdo</a>. Originally made for Jekyll.
      ''}
      </p>
    </div>

    <ul class="sidebar-nav">
      <li><a href="/">Home</a></li>
      ${mapTemplate (menu: ''
        <li><a href="${conf.siteUrl}/${menu.href}">${menu.title}</a></li>
      '') data.menus}
    </ul>

    <p>&copy; 2016. All rights reserved.</p>
  </div>
</div>
''
