env: let
  template = {templates, ...}: args:
    templates.lib.js.jquery
    + templates.lib.js.bootstrap
    + templates.lib.js.highlightjs
    + templates.lib.js.mathjax
    + templates.services.google-analytics
    + templates.services.piwik
    + (templates.partials.js-custom args)
    + (templates.partials.js-extra args);
in
  env.lib.template.documentedTemplate {
    description = ''
      Template loading the javascript files. Include the following templates:

      - <<templates.lib.js.jquery>>
      - <<templates.lib.js.bootstrap>>
      - <<templates.lib.js.highlightjs>>
      - <<templates.lib.js.mathjax>>
      - <<templates.services.google-analytics>>
      - <<templates.services.piwik>>
      - <<templates.partials.js-custom>>
      - <<templates.partials.js-extra>>
    '';
    inherit env template;
  }
