{ templates, lib, ... }:
with lib;
normalTemplate (data: {
  content = templates.blocks.basic (data // {
    content = ''
      <div class="row">
        ${mapTemplateWithIndex (index: project: ''
        <div class="col-md-4 col-sm-6 portfolio-item">
          <a href="#portfolioModal${toString index}" class="portfolio-link" data-toggle="modal">
            <div class="portfolio-hover">
              <div class="portfolio-hover-content">
                <i class="fa fa-plus fa-3x"></i>
              </div>
            </div>
            <img src="${templates.url "/img/portfolio/${project.preview}"}" class="img-responsive" alt="">
          </a>
          <div class="portfolio-caption">
            <h4>${project.title}</h4>
            <p class="text-muted">${project.category}</p>
          </div>
        </div>
        '') data.items}
      </div>
    '';
    post = ''
      ${mapTemplateWithIndex (index: project: ''
        <div class="portfolio-modal modal fade" id="portfolioModal${toString index}" tabindex="-1" role="dialog" aria-hidden="true">
          <div class="modal-content">
            <div class="close-modal" data-dismiss="modal">
              <div class="lr">
                <div class="rl">
                </div>
              </div>
            </div>
            <div class="container">
              <div class="row">
                <div class="col-lg-8 col-lg-offset-2">
                  <div class="modal-body">
                    <h2>${project.title}</h2>
                    <p class="item-intro text-muted">${project.subtitle}</p>
                    <img class="img-responsive img-centered" src="${templates.url "/img/portfolio/${project.preview}"}" alt="">
                    ${project.content}
                    <ul class="list-inline">
                      <li>${project.date}</li>
                      <li>Client: <a href="${project.clientLink}">${project.client}</a></li>
                      <li>Category: ${project.category}</li>
                    </ul>
                    <button type="button" class="btn btn-primary" data-dismiss="modal"><i class="fa fa-times"></i>Close project</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      '') data.items}
    '';
  });
  extraCSS = { href = templates.url "/css/portfolio.css"; };
})
