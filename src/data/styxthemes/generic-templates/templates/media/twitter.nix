env: let
  template = {
    templates,
    lib,
    ...
  }: {
    user,
    width ? null,
    height ? null,
  }:
    with lib.lib; let
      dataWidth = optionalString (width != null) (" " + lib.template.htmlAttr "data-width" (toString width));
      dataHeight = optionalString (height != null) (" " + lib.template.htmlAttr "data-height" (toString height));
    in ''      <a class="twitter-timeline"${dataWidth + dataHeight} href="https://twitter.com/${user}">Tweets by ${user}</a>
          <script async="async" src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
    '';
in
  env.lib.template.documentedTemplate {
    description = "Template to embed a twitter timeline.";

    arguments = {
      user = {
        description = "Twitter user.";
        type = "String";
      };
      height = {
        description = "Embedded timeline height.";
        type = "Int";
      };
      width = {
        description = "Embedded timeline width.";
        type = "Int";
      };
    };

    inherit env template;
  }
