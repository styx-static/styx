{
  templates,
  lib,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (data: {
    content = templates.blocks.basic (data
      // {
        content = ''
          <div class="row">
            ${lib.template.mapTemplate (member: ''
              <div class="col-sm-4">
                <div class="team-member">
                  <img src="${templates.url member.img}" class="img-responsive img-circle" alt="">
                  <h4>${member.name}</h4>
                  <p class="text-muted">${member.title}</p>
                  ${optionalString (member ? social) ''
                <ul class="list-inline social-buttons">
                  ${lib.template.mapTemplate (social: ''
                    <li><a href="${social.link}"><i class="fa fa-${social.type}"></i></a></li>
                  '')
                  member.social}
                </ul>''}
                </div>
              </div>
            '')
            data.items}
          </div>
          ${optionalString (data ? description) ''
            <div class="row">
              <div class="col-lg-8 col-lg-offset-2 text-center">
                <p class="large text-muted">${data.description}</p>
              </div>
            </div>''}
        '';
      });
    extraCSS = {href = templates.url "/css/team.css";};
  })
