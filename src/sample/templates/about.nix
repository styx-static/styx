{ templates, ... }:
page:
let
  content =
    ''
    <div class="post">

      <article class="post-content">
        <h1>${page.title}</h1>

        <p>Styx is a static site generator in Nix expression language.</p>
      </article>

    </div>
    '';
in
  templates.base (page // { inherit content; })
