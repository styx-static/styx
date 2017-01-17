{ conf, templates, lib, ... }:
with lib;
optionalString (conf.theme.experiences.items != [])
''
<section class="section experiences-section">
  <h2 class="section-title">${templates.icon.fa conf.theme.experiences.icon}${conf.theme.experiences.title}</h2>
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
  '') conf.theme.experiences.items}
</section><!--//section-->
''
