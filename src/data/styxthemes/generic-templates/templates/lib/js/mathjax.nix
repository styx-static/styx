env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }:
    with lib.lib; let
      cnf = conf.theme.lib.mathjax;
    in
      optionalString cnf.enable
      (templates.tag.script {
        src = "//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML";
        crossorigin = "anonymous";
      });
in
  env.lib.template.documentedTemplate {
    description = "Template loading the MathJax javascript library. Controlled by `conf.theme.lib.mathjax.*` configuration options.";
    inherit env template;
  }
