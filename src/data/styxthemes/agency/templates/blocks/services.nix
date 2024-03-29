{
  templates,
  lib,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (
    data:
      templates.blocks.basic (data
        // {
          content = ''
            <div class="row text-center">
              ${lib.template.mapTemplate (item: ''
                <div class="col-md-4">
                  <span class="fa-stack fa-4x">
                    <i class="fa fa-circle fa-stack-2x text-primary"></i>
                    <i class="fa ${item.icon} fa-stack-1x fa-inverse"></i>
                  </span>
                  <h4 class="service-heading">${item.title}</h4>
                  ${optionalString (item ? content) ''<div class="text-muted">${item.content}</div>''}
                </div>
              '')
              data.items}
            </div>
          '';
        })
  )
