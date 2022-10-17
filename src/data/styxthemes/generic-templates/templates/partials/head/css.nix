env: let
  template = {templates, ...}: args:
    templates.lib.css.bootstrap
    + templates.lib.css.font-awesome
    + templates.lib.css.highlightjs
    + templates.lib.css.googlefonts
    + (templates.partials.head.css-custom args)
    + (templates.partials.head.css-extra args);
in
  env.lib.template.documentedTemplate {
    description = ''
      Template loading the css files. Include the following templates:

      - <<templates.lib.css.bootstrap>>
      - <<templates.lib.css.font-awesome>>
      - <<templates.lib.css.highlightjs>>
      - <<templates.lib.css.googlefonts>>
      - <<templates.partials.head.css-custom>>
      - <<templates.partials.head.css-extra>>
    '';
    inherit env template;
  }
