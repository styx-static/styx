{ conf, lib, templates, ... }:
with lib;
optionalString (conf.theme.contact.items != [])
''
<div class="contact-container container-block">
  <ul class="list-unstyled contact-list">
    ${mapTemplate (item: '' 
      <li class="${item.type}">${templates.icon.fa item.icon}<a href="${item.url}">${item.title}</a></li>
    '') conf.theme.contact.items}
  </ul>
</div><!--//contact-container-->
''
