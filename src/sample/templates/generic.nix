{ templates, ... }:
page:
let
  content =
    ''
    <div>
      ${page.content}
    </div>
    '';
in
  templates.base (page // { inherit content; })
