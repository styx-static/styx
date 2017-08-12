{ conf, lib, ... }:
with lib;
block:
{
  content = ''
    <div class="education-container container-block">
      <h2 class="container-block-title">${block.title}</h2>
      ${mapTemplate (item: ''
      <div class="item">
        <h4 class="degree">${item.degree}</h4>
        <h5 class="meta">${item.college}</h5>
        <div class="time">${item.dates}</div>
      </div><!--//item-->
      '') block.items}
    </div><!--//education-container-->
  '';
}
