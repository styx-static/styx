{
  conf,
  data,
  lib,
  templates,
  ...
}: block:
with lib.lib; {
  content = ''
    <section class="section projects-section">
      <h2 class="section-title">${templates.icon.font-awesome block.icon}${block.title}</h2>
      ${lib.template.mapTemplate (item: ''
        <div class="item">
          <span class="project-title"><a href="${item.url}">${item.title}</a></span>
          <div class="project-tagline">${item.content}</div>
        </div><!--//item-->
      '')
      block.items}
    </section><!--//section-->
  '';
}
