{ lib, ... }:
page:
with lib;
let content =
  ''
    <div class="post">
      <h1>${page.title}</h1>
      <span class="post-date">${with (parseDate page.date); "${D} ${b} ${Y}"}</span>
      ${page.content}
    </div>
  '';
in
  page // { inherit content; }
