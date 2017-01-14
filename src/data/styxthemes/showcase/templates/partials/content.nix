{ templates, lib, ... }:
{ page }:
with lib;
''
<div class="page-content">
  <div class="container wrapper">
    <div class="row">
      <div class="col-md-9">
        ${optionalString (page ? breadcrumbs) (templates.bootstrap.breadcrumbs page)}
        ${page.content}
      </div>
      <div class="col-md-3">
        ${templates.partials.sidebar}
      </div>
    </div>
  </div>
</div>''
