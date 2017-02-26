env:

let template = { conf, lib, templates,  ... }:
  let cnf = conf.theme.lib.mathjax;
  in
  lib.optionalString (cnf.enable == true)
    (templates.tag.script {
      src = "//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML";
      crossorigin = "anonymous";
    });

in env.lib.documentedTemplate {
  description = "Template loading the MathJax javascript library. Controlled by `conf.theme.lib.mathjax.*` configuration options.";
  inherit env template;
}
