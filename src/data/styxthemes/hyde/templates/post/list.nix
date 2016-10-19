{ conf, lib, ... }:
with lib;
page:
''
  <div class="post">
    <h1><a href="${conf.siteUrl}/${page.href}">${page.title}</a></a></h1>
    <span class="post-date">${with (parseDate page.date); "${D} ${b} ${Y}"}</span>
    ${page.intro}
  </div>
''
