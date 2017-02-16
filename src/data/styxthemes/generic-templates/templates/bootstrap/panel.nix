env:

let template = { lib, ... }:
  { heading   ? null
  , body      ? null
  , footer    ? null
  , listGroup ? null
  , type      ? "default" }:
  with lib;
  let
    h = optionalString (heading   != null) "<div class=\"panel-heading\">${heading}</div>\n";
    b = optionalString (body      != null) "<div class=\"panel-body\">${body}</div>\n";
    l = optionalString (listGroup != null) listGroup;
    f = optionalString (footer    != null) "<div class=\"panel-footer\">${footer}</div>\n";
  in
  concatStringsSep "" [ "<div class=\"panel panel-${type}\">\n" h b l f ''</div>'' ];

in with env.lib; documentedTemplate {
  description = "Generate a bootstrap panel.";
  arguments = {
    heading = {
      description = "Content of the panel heading, set to `null` to disable the heading.";
      type = "null | String";
      default = null;
    };
    body = {
      description = "Content of the panel body, set to `null` to disable the body.";
      type = "null | String";
      default = null;
    };
    listGroup = {
      description = "Content of the panel list group, set to `null` to disable the body.";
      type = "null | String";
      default = null;
    };
    footer = {
      description = "Content of the panel footer, set to `null` to disable the footer.";
      type = "null | String";
      default = null;
    };
    type = {
      description = "Type of the panel.";
      type = ''"default" | "primary" | "success" | "info" | "warning" | "danger"'';
      default = "default";
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.bootstrap.panel {
        type    = "danger";
        heading = '''<h3 class="panel-title">Panel title</h3>''';
        body    = "Panel content";
      }
    '';
    code = with env;
      templates.bootstrap.panel {
        type    = "danger";
        heading = ''<h3 class="panel-title">Panel title</h3>'';
        body    = "Panel content";
      }
    ;
  }) ];
  inherit env template;
}
