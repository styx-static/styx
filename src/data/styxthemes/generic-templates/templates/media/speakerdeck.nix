env: let
  template = {
    templates,
    lib,
    ...
  }: {
    id,
    slide ? null,
  }:
    with lib.lib;
      templates.tag.script (
        {
          src = "//speakerdeck.com/assets/embed.js";
          class = "speakerdeck-embed";
          data-id = id;
          async = "async";
          data-ratio = "1.33333333333333";
        }
        // (optionalAttrs (slide != null) {data-slide = toString slide;})
      );
in
  env.lib.template.documentedTemplate {
    description = "Template to embed a speakerdeck presentation.";

    arguments = {
      id = {
        description = "Presentation id.";
        type = "String";
      };
      slide = {
        description = "Slide to display.";
        type = "Null | Int";
        default = null;
      };
    };

    inherit env template;
  }
