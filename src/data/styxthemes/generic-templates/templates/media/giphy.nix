env:

let template = { templates, lib, ... }:
    { id
    , height
    , width }:
    ''<iframe src="//giphy.com/embed/${id}" width="${toString width}" height="${toString height}" frameBorder="0" class="giphy-embed" allowFullScreen></iframe>
    '';

in env.lib.documentedTemplate {
  description = "Template to embed a Giphy gif.";

  arguments = {
    id = {
      description = "Giphy id.";
      type = "String";
    };
    height = {
      description = "Embedded gif height.";
      type = "Int";
    };
    width = {
      description = "Embedded gif width.";
      type = "Int";
    };
  };

  inherit env template;
}
