env:

let template = { templates, ... }:
  args:
  ''
  <body>
  ${(templates.partials.content-pre  args)
  + (templates.partials.content      args)
  + (templates.partials.content-post args)
  + (templates.partials.js args)
  }</body>
  '';

in with env.lib; documentedTemplate {
  description = ''
    Template responsible for `body` tag rendering. `body` is divided in the following templates:

    * <<templates.partials.content-pre>>
    * <<templates.partials.content>>
    * <<templates.partials.content-post>>
    * <<templates.partials.js>>
    ** <<templates.lib.js.jquery>>
    ** <<templates.lib.js.bootstrap>>
    ** <<templates.partials.js-custom>>
    ** <<templates.partials.js-extra>>

  '';
  inherit env template;
}
