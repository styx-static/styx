env:

let template = { templates, lib, ... }:
    { id
    , height ? 360
    , width  ? 640 }:
    with lib;
    ''<iframe src="https://player.vimeo.com/video/${id}" width="${toString width}" height="${toString height}" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
    '';

in env.lib.documentedTemplate {
  description = "Template to embed a Vimeo video.";

  arguments = {
    id = {
      description = "Video id.";
      type = "String";
    };
    height = {
      description = "Embedded video height.";
      type = "Int";
      default = 360;
    };
    width = {
      description = "Embedded video width.";
      type = "Int";
      default = 640;
    };
  };

  inherit env template;
}
