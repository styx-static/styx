env:

let template = { lib, ... }: attrs: "<link ${lib.htmlAttrs attrs} />\n";

in with env.lib; documentedTemplate {
  description = ''
    Template generating a `link` tag.
  '';
  inherit env template;
}
