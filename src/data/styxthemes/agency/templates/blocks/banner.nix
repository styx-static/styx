{ lib, templates, ... }:
with lib;
normalTemplate (banner: {
  content = ''
    <div class="banner" ${optionalString (banner ? id) htmlAttr "id" banner.id}>
      <div class="container">
      ${banner.content}
      </div>
    </div>
  '';
  /* Loading custom css
  */
  extraCSS = { href = templates.url "/css/banner.css"; };
})
