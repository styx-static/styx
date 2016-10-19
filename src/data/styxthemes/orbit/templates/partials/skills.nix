{ conf, lib, templates, ... }:
with lib;
optionalString (conf.theme.skills != null)
''
<section class="skills-section section">
  <h2 class="section-title">${templates.icon.fa conf.theme.skills.icon}${conf.theme.skills.title}</h2>
  <div class="skillset">
    ${mapTemplate (item: ''
      <div class="item">
        <h3 class="level-title">${item.skill}</h3>
        <div class="level-bar">
          <div class="level-bar-inner" data-level="${item.level}">
          </div>                                      
        </div><!--//level-bar-->                                 
      </div><!--//item-->
    '') conf.theme.skills.items}
  </div>  
</section><!--//skills-section-->
''
