{
  lib,
  templates,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (banner: {
    content = ''
      <div class="banner" ${optionalString (banner ? id) lib.template.htmlAttr "id" banner.id}>
        <div class="container">
        ${banner.content}
        </div>
      </div>
    '';
    /*
    Loading custom css
    */
    extraCSS = {href = templates.url "/css/banner.css";};
  })
