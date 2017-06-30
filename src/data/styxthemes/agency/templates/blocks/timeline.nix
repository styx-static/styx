{ templates, lib, ... }:
with lib;
normalTemplate (data: {
  content = templates.blocks.basic (data // {
    content = ''
      <div class="row">
        <div class="col-lg-12">
          <ul class="timeline">
            ${mapTemplateWithIndex (index: event: ''
              <li${optionalString (isOdd index) " ${htmlAttr "class" "timeline-inverted"}"}>
                <div class="timeline-image">
                  <img class="img-circle img-responsive" src="${templates.url event.img}" alt="">
                </div>
                <div class="timeline-panel">
                  <div class="timeline-heading">
                    <h4>${event.title}</h4>
                    <h4 class="subheading">${event.subtitle}</h4>
                  </div>
                  <div class="timeline-body">
                    <div class="text-muted">${event.content}</div>
                  </div>
                </div>
              </li>
            '') data.items}
            ${optionalString (data ? endpoint) ''
            <li class="timeline-inverted">
              <div class="timeline-image">
                <h4>${data.endpoint}</h4>
              </div>
              </li>
            ''}
          </ul>
        </div>
      </div>
    '';
  });
  extraCSS = { href = templates.url "/css/timeline.css"; };
})
