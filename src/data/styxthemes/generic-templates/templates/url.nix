env:

let template = { conf, lib, ... }:
  arg: if   lib.isAttrs arg
       then "${conf.siteUrl}${arg.path}"
       else "${conf.siteUrl}${arg}";

in with env.lib; documentedTemplate {
  description = "Generate a full url from a path or a page by using `conf.siteUrl`.";
  arguments = [
    {
      name = "arg";
      description = "Path or Page to generate the url.";
      type = "String | Page";
    }
  ];
  examples = [ (mkExample {
    literalCode  = ''templates.url "/foo.html"'';
    code = with env; templates.url "/foo.html";
  })
  (mkExample {
    literalCode  = ''templates.url { title = "About"; path = "/about.html"; }'';
    code = with env; templates.url { title = "About"; path = "/about.html"; };
  }) ];
  inherit env template;
}
