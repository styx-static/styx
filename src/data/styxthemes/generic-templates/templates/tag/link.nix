env:

let template = { lib, ... }: attrs: "<link ${lib.htmlAttrs attrs} />\n";

in with env.lib; documentedTemplate {
  description = ''
    Template generating a `link` tag.
  '';
  examples = [ (mkExample {
    literalCode  = ''templates.tag.link { href = "/feed.atom"; rel = "alternate"; type = "application/atom+xml"; }'';
    code = with env; templates.tag.link { href = "/feed.atom"; rel = "alternate"; type = "application/atom+xml"; };
  }) ];
  inherit env template;
}
