{ conf, lib, data, ... }:
with lib;
optionalString (conf.theme.team != null)
''
<!-- Team Section -->
<section id="team" class="bg-light-gray">
  <div class="container">
    <div class="row">
      <div class="col-lg-12 text-center">
        <h2 class="section-heading">${conf.theme.team.title}</h2>
        <h3 class="section-subheading text-mutedwith ">${conf.theme.team.subtitle}</h3>
      </div>
    </div>
    <div class="row">
      ${mapTemplate (member: ''
        <div class="col-sm-4">
          <div class="team-member">
            <img src="${conf.siteUrl}/img/team/${member.img}" class="img-responsive img-circle" alt="">
            <h4>${member.name}</h4>
            <p class="text-muted">${member.position}</p>
            <ul class="list-inline social-buttons">
              ${mapTemplate (social: ''
                <li><a href="${social.link}"><i class="fa fa-${social.type}"></i></a></li>
              '') member.social}
            </ul>
          </div>
        </div>
      '') data.team}
    </div>
    <div class="row">
      <div class="col-lg-8 col-lg-offset-2 text-center">
        <p class="large text-muted">${conf.theme.team.description}</p>
      </div>
    </div>
  </div>
</section>
''
