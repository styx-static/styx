{ templates, ... }:
page:
let
  content =
    ''
    <div>
      <h1>Page not found, Error 404</h1>
    </div>
    '';
in
  page // { inherit content; }

