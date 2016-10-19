{ conf, data, lib, templates, ... }:
with lib;
optionalString (conf.theme.projects != null)
''
<section class="section projects-section">
  <h2 class="section-title">${templates.icon.fa conf.theme.projects.icon}${conf.theme.projects.title}</h2>
  ${mapTemplate (item: ''
    <div class="item">
      <span class="project-title"><a href="${item.url}">${item.title}</a></span>
      <div class="project-tagline">${item.content}</div>
    </div><!--//item-->
  '') data.projects}
</section><!--//section-->
''
