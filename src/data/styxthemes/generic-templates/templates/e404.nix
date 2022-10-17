env: let
  template = {lib, ...}:
    lib.template.normalTemplate {
      content = ''
        <div>
          <h1>Page not found, Error 404</h1>
        </div>
      '';
      title = "404";
    };
in
  env.lib.template.documentedTemplate {
    description = "Basic template for error 404 page, can be overriden to fit needs.";
    inherit env template;
  }
