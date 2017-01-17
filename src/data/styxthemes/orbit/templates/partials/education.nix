{ conf, lib, ... }:
with lib;
optionalString (conf.theme.education.items != [])
''
<div class="education-container container-block">
  <h2 class="container-block-title">${conf.theme.education.title}</h2>
  ${mapTemplate (item: ''
  <div class="item">
    <h4 class="degree">${item.degree}</h4>
    <h5 class="meta">${item.college}</h5>
    <div class="time">${item.dates}</div>
  </div><!--//item-->
  '') conf.theme.education.items}
</div><!--//education-container-->
''
