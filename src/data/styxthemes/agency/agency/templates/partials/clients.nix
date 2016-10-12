{ conf, lib, data, ... }:
with lib;
optionalString (data ? clients)
''
<!-- Clients Aside -->
<aside class="clients">
  <div class="container">
    <div class="row">
      ${mapTemplate (client: ''
        <div class="col-md-3 col-sm-6">
          <a href="${client.link}">
            <img src="${conf.siteUrl}/img/logos/${client.logo}" class="img-responsive img-centered" alt="">
          </a>
        </div>
      '') data.clients}
    </div>
  </div>
</aside>
''
