env:

let template = { templates, lib, ... }:
  { embedCode, width ? 640, height ? 480 }:
  ''<iframe src='https://www.slideshare.net/slideshow/embed_code/60836660' width='${toString width}' height='${toString height}' allowfullscreen="allowfullscreen" webkitallowfullscreen="webkitallowfullscreen=" mozallowfullscreen="mozallowfullscreen"></iframe>
  ''
  ;

in env.lib.documentedTemplate {
  description = "Template to embed a slideshare presentation.";

  arguments = {
    embedCode = {
      description = "Slides embed code.";
      type = "String";
    };
    height = {
      description = "Embedded video height.";
      type = "Int";
      default = 315;
    };
    width = {
      description = "Embedded video width.";
      type = "Int";
      default = 560;
    };
  };

  inherit env template;
}
