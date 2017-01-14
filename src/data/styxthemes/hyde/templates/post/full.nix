{ lib, templates, ... }:
with lib;
normalTemplate (page: ''
  <div class="post">
    <h1>${page.title}</h1>
    <span class="post-date">${with (parseDate page.date); "${D} ${b} ${Y}"}</span>
    ${page.content}

    ${optionalString (page ? pages) (templates.partials.pager { inherit (page) pages index; })} 
  </div>
'')
