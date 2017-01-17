{ conf, lib, templates, ... }:
with lib;
optionalString (conf.theme.summary.content != null)
''
<section class="section summary-section">
  <h2 class="section-title">${templates.icon.fa conf.theme.summary.icon}${conf.theme.summary.title}</h2>
  <div class="summary">
    <p>${conf.theme.summary.content}</p>
  </div><!--//summary-->
</section><!--//section-->
''
