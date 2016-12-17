{ lib, templates, ... }:
page:
with lib;
let content =
  ''
    <div class="post">
      <h1>${page.title}</h1>
      <span class="post-date">${with (parseDate page.date); "${D} ${b} ${Y}"}</span>
      ${page.content}

      ${optionalString (page ? pages) (templates.partials.pagination { pages = page.pages; index = page.index; })}
    </div>
  '';
in
  page // { inherit content; }
