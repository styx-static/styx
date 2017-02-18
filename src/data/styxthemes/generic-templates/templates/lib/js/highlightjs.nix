env:

let template = { conf, lib, templates,  ... }:
  let cnf = conf.theme.lib.highlightjs;
  in
  lib.optionalString (cnf.enable == true) 
    (templates.tag.script {
      src = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/highlight.min.js";
      crossorigin = "anonymous";
    })
  + (lib.mapTemplate (lang: (templates.tag.script {
      src = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/${cnf.version}/languages/${lang}.min.js";
      crossorigin = "anonymous";
    })) cnf.extraLanguages)
  + ''<script>hljs.initHighlightingOnLoad();</script>''
  ;

in env.lib.documentedTemplate {
  description = "Template loading the highlightjs javascript library. Controlled by `conf.theme.lib.highlightjs.*` configuration options.";
  inherit env template;
}
