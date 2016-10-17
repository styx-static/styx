{ templates, ... }:
page:
let
  content =
    ''
    <section>
      <header>${page.title}</header>
      <p>${page.intro}</p>
    </section>
    '';
in
  page // { inherit content; }

