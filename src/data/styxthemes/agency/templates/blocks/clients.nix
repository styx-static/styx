{ templates, lib, ... }:
with lib;
normalTemplate (data: ''
<aside class="${data.id}">
  <div class="container">
    <div class="row">
      ${mapTemplate (item: ''
        <div class="col-md-3 col-sm-6">
          ${optionalString (item ? link) ''<a href="${templates.url item.link}">''}
            <img src="${templates.url item.img}" class="img-responsive img-centered" alt="">
          ${optionalString (item ? link) ''</a>''}
        </div>
      '') data.items}
    </div>
  </div>
</aside>
'')
