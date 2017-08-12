{ conf, templates, lib, ... }:
block:
with lib;
{
  content = ''
    <section class="section experiences-section">
      <h2 class="section-title">${templates.icon.font-awesome block.icon}${block.title}</h2>
      ${mapTemplate (item: ''
      <div class="item">
        <div class="meta">
          <div class="upper-row">
            <h3 class="job-title">${item.position}</h3>
            <div class="time">${item.dates}</div>
          </div><!--//upper-row-->
          <div class="company">${item.company}</div>
        </div><!--//meta-->
        <div class="details">
        ${item.content}
        </div><!--//details-->
      </div><!--//item-->
      '') block.items}
    </section><!--//section-->
  '';
}
