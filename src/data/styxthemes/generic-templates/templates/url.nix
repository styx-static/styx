env: let
  template = {
    conf,
    lib,
    ...
  }:
    with lib.lib;
      arg:
        if isAttrs arg
        then "${conf.siteUrl}${arg.path}"
        else if (match "^(http|https|ftp|mailto)://.*$" arg) != null
        then arg
        else conf.siteUrl + arg;
in
  env.lib.template.documentedTemplate {
    description = "Generate a full url from a path or a page by using `conf.siteUrl`.";
    arguments = [
      {
        name = "arg";
        description = "Path or Page to generate the url.";
        type = "String | Page";
      }
    ];
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''templates.url "/foo.html"'';
        code = with env; templates.url "/foo.html";
      })
      (env.lib.utils.mkExample {
        literalCode = ''templates.url { title = "About"; path = "/about.html"; }'';
        code = with env;
          templates.url {
            title = "About";
            path = "/about.html";
          };
      })
    ];
    inherit env template;
  }
