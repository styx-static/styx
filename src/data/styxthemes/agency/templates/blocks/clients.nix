{
  templates,
  lib,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (data: {
    content = ''
      <aside class="${data.id}">
        <div class="container">
          <div class="row">
            ${lib.template.mapTemplate (item: ''
          <div class="col-md-3 col-sm-6">
            ${optionalString (item ? link) ''<a href="${templates.url item.link}">''}
              <img src="${templates.url item.img}" class="img-responsive img-centered" alt="">
            ${optionalString (item ? link) ''</a>''}
          </div>
        '')
        data.items}
          </div>
        </div>
      </aside>
    '';
    extraCSS = {href = templates.url "/css/clients.css";};
  })
