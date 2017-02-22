env:

let template = { templates, lib, ... }:
    { user
    , id
    , file ? null }:
    with lib;
    templates.tag.script {
      src = "https://gist.github.com/${user}/${id}.js${optionalString (file != null) "?file=${file}"}";
    };

in env.lib.documentedTemplate {
  description = "Template to embed a github gist.";

  arguments = {
    user = {
      description = "Gist owner.";
      type = "String";
    };
    id = {
      description = "Gist id.";
      type = "String";
    };
    file = {
      description = "Gist file.";
      type = "Null | String";
      default = null;
    };
  };

  inherit env template;
}
