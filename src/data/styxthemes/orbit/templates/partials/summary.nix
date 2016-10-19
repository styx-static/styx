{ conf, lib, data, templates, ... }:
with lib;
optionalString (data ? summary)
''
<section class="section summary-section">
  <h2 class="section-title">${templates.icon.fa data.summary.icon}${data.summary.title}</h2>
  <div class="summary">
    <p>${data.summary.content}</p>
  </div><!--//summary-->
</section><!--//section-->
''
