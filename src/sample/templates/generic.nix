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
  page // { inherit content; }
