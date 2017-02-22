env:

let template = { templates, lib, ... }:
  { id, slide ? null }:
    templates.tag.script ({
      src = "https://speakerdeck.com/assets/embed.js";
      class = "speakerdeck-embed";
      data-id = id;
      async = "async";
      data-ratio = "1.33333333333333";
    }
    // (lib.optionalAttrs (slide != null) { data-slide = lib.toString slide; })
  );

in env.lib.documentedTemplate {
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
