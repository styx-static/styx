{ conf, lib, templates, ... }:
block:
with lib;
{
  content = ''
    <section class="skills-section section">
      <h2 class="section-title">${templates.icon.font-awesome block.icon}${block.title}</h2>
      <div class="skillset">
        ${mapTemplate (item: ''
          <div class="item">
            <h3 class="level-title">${item.skill}</h3>
            <div class="level-bar">
              <div class="level-bar-inner" data-level="${item.level}">
              </div>                                      
            </div><!--//level-bar-->                                 
          </div><!--//item-->
        '') block.items}
      </div>  
    </section><!--//skills-section-->
  '';
}
