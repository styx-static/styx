{ templates, ... }:
page:
let
  content =
    ''
    <div>
      <h1>${page.title}</h1>
      ${page.content}
    </div>
    '';
in
  page // { inherit content; }
