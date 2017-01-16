{ conf, lib, data, ... }:
with lib;
optionalString (conf.theme.portfolio.items != [])
''
<!-- Portfolio Modals -->
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
              <img class="img-responsive img-centered" src="${conf.siteUrl}/img/portfolio/${project.img}" alt="">
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
'') conf.theme.portfolio.items}
''
