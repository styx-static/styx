{ lib, conf, data, ... }:
with lib;
optionalString (conf.theme.about.items != [])
''
<!-- About Section -->
<section id="about">
  <div class="container">
    <div class="row">
      <div class="col-lg-12 text-center">
        <h2 class="section-heading">${conf.theme.about.title}</h2>
        <h3 class="section-subheading text-muted">${conf.theme.about.subtitle}</h3>
      </div>
    </div>
    <div class="row">
      <div class="col-lg-12">
        <ul class="timeline">
          ${mapTemplate (event: ''
            <li${optionalString (isOdd event.index) " ${htmlAttr "class" "timeline-inverted"}"}>
              <div class="timeline-image">
                <img class="img-circle img-responsive" src="${conf.siteUrl}/img/about/${event.img}" alt="">
              </div>
              <div class="timeline-panel">
                <div class="timeline-heading">
                  <h4>${event.date}</h4>
                  <h4 class="subheading">${event.title}</h4>
                </div>
                <div class="timeline-body">
                  <div class="text-muted">${event.content}</div>
                </div>
              </div>
            </li>
          '') conf.theme.about.items}
          <li class="timeline-inverted">
            <div class="timeline-image">
              <h4>${conf.theme.about.endpoint}</h4>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</section>
''
