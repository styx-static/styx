{ lib, conf, data, ... }:
with lib;
optionalString (conf.theme.portfolio.items != [])
''
<!-- Portfolio Grid Section -->
<section id="portfolio" class="bg-light-gray">
  <div class="container">
    <div class="row">
      <div class="col-lg-12 text-center">
        <h2 class="section-heading">${conf.theme.portfolio.title}</h2>
        <h3 class="section-subheading text-muted">${conf.theme.portfolio.subtitle}</h3>
      </div>
    </div>
    <div class="row">
      ${mapTemplateWithIndex (index: project: ''
      <div class="col-md-4 col-sm-6 portfolio-item">
        <a href="#portfolioModal${toString index}" class="portfolio-link" data-toggle="modal">
          <div class="portfolio-hover">
            <div class="portfolio-hover-content">
              <i class="fa fa-plus fa-3x"></i>
            </div>
          </div>
          <img src="${conf.siteUrl}/img/portfolio/${project.preview}" class="img-responsive" alt="">
        </a>
        <div class="portfolio-caption">
          <h4>${project.title}</h4>
          <p class="text-muted">${project.category}</p>
        </div>
      </div>
      '') conf.theme.portfolio.items}
    </div>
  </div>
</section>
''
