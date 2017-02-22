env:

let template = { templates, lib, ... }:
    { id
    , height ? 315
    , width  ? 560 }:
    with lib;
    ''<iframe width="${toString width}" height="${toString height}" src="https://www.youtube.com/embed/${id}?ecver=1" frameborder="0" allowfullscreen></iframe>
    '';

in env.lib.documentedTemplate {
  description = "Template to embed a Youtube video.";

  arguments = {
    id = {
      description = "Video id.";
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
