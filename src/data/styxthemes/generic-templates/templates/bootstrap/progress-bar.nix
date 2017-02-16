env:

let template = { lib, ... }:
  { type ? null
  , stripped ? false
  , value }:
  with lib;
  let typeClass = optionalString (type != null) "progress-bar-${type}";
      strippedClass = optionalString stripped "progress-bar-striped";
      classes = filter (x: x != "") [ "progress-bar" typeClass strippedClass ];
  in
  ''
  <div class="progress">
    <div ${htmlAttr "class" classes} role="progressbar" aria-valuenow="${toString value}" aria-valuemin="0" aria-valuemax="100" style="width: ${toString value}%"><span class="sr-only">${toString value}% Complete</span></div>
  </div>
  '';

in with env.lib; documentedTemplate {
  description = "Generate a bootstrap progress bar.";
  arguments = {
    value = {
      description = "Value of the progress bar as percentage.";
      type = "Integer";
    };
    type = {
      description = "Type of the progress bar.";
      type = ''"success" | "info" | "warning" | "danger"'';
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.bootstrap.progress-bar { value = 60; }
    '';
    code = with env;
      templates.bootstrap.progress-bar { value = 60; }
    ;
  }) ];
  inherit env template;
}
