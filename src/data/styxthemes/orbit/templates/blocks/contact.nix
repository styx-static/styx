{ conf, lib, templates, ... }:
block:
with lib;
{
  content = ''
    <div class="contact-container container-block">
      <ul class="list-unstyled contact-list">
        ${mapTemplate (item: '' 
          <li class="${item.type}">${templates.icon.font-awesome item.icon} <a href="${item.url}">${item.title}</a></li>
        '') block.items}
      </ul>
    </div><!--//contact-container-->
  '';
}
