env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.highlightjs;
    in
      optionalString cnf.enable
      ((templates.tag.script {
          src = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/highlight.min.js";
          crossorigin = "anonymous";
        })
        + (lib.template.mapTemplate (lang: (templates.tag.script {
            src = "//cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/languages/${lang}.min.js";
            crossorigin = "anonymous";
          }))
          cnf.extraLanguages)
        + "<script>hljs.initHighlightingOnLoad();</script>\n");
in
  env.lib.template.documentedTemplate {
    description = "Template loading the highlightjs javascript library. Controlled by `conf.theme.lib.highlightjs.*` configuration options.";
    inherit env template;
  }
