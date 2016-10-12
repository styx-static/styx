{ lib, conf, data, ... }:
with lib;
optionalString (conf.theme.services != null)
''
<!-- Services -->
<section id="services">
  <div class="container">
    <div class="row">
      <div class="col-lg-12 text-center">
        <h2 class="section-heading">${conf.theme.services.title}</h2>
        <h3 class="section-subheading text-muted">${conf.theme.services.subtitle}</h3>
      </div>
    </div>
      <div class="row text-center">
        ${mapTemplate (service: ''
        <div class="col-md-4">
          <span class="fa-stack fa-4x">
            <i class="fa fa-circle fa-stack-2x text-primary"></i>
            <i class="fa ${service.icon} fa-stack-1x fa-inverse"></i>
          </span>
          <h4 class="service-heading">${service.title}</h4>
          <div class="text-muted">${service.content}</div>
        </div>
        '') data.services}
      </div>
  </div>
</section>
''
