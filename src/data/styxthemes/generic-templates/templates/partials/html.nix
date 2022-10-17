env: let
  template = {
    templates,
    lib,
    conf,
    html ? {},
    ...
  }: args:
    with lib.lib; let
      lang =
        html.lang
        or (
          if hasAttrByPath ["html" "lang"] conf.theme
          then conf.theme.html.lang
          else "en"
        );
    in ''      <html ${lib.template.htmlAttr "lang" lang}>
        ${
        (templates.partials.head.default args)
        + (templates.partials.body args)
      }</html>'';
in
  env.lib.template.documentedTemplate {
    description = "Template responsible for generating the `html` tag, includes <<templates.partials.head.default>> and <<templates.partials.body>>.";
    inherit env template;
  }
