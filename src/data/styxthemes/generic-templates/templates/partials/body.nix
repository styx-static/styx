env: let
  template = {
    templates,
    lib,
    ...
  }: {page, ...} @ args:
    with lib.lib; let
      id = optionalString (hasAttrByPath ["body" "id"] page) " ${lib.template.htmlAttr "id" page.body.id}";
      class = optionalString (hasAttrByPath ["body" "class"] page) " ${lib.template.htmlAttr "class" page.body.class}";
    in ''
      <body${id}${class}>
      ${
        (templates.partials.content-pre args)
        + (templates.partials.content args)
        + (templates.partials.content-post args)
        + (templates.partials.js args)
      }</body>
    '';
in
  env.lib.template.documentedTemplate {
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
