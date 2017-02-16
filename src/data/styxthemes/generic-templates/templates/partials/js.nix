env:

let template = { templates, ... }:
  args:
    templates.lib.js.jquery
  + templates.lib.js.bootstrap
  + (templates.partials.js-custom args)
  + (templates.partials.js-extra  args)
  + templates.services.google-analytics
  + templates.services.mixpanel;

in with env.lib; documentedTemplate {
  description = ''
    Template loading the javascript files. Include the following templates:

    - <<templates.lib.js.jquery>>
    - <<templates.lib.js.bootstrap>>
    - <<templates.partials.js-custom>>
    - <<templates.partials.js-extra>>
    - <<templates.services.google-analytics>>
    - <<templates.services.mixpanel>>
  '';
  inherit env template;
}
