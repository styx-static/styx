{ conf, lib, templates, ... }:
block:
with lib;
{
  content = ''
    <section class="section summary-section">
      <h2 class="section-title">${templates.icon.font-awesome block.icon}${block.title}</h2>
      <div class="summary">
        <p>${block.content}</p>
      </div><!--//summary-->
    </section><!--//section-->
  '';
}
