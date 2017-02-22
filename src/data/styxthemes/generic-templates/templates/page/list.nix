env:

let template = { templates, lib, ... }:
  lib.normalTemplate (page:
    "<li>${templates.tag.ilink { to = page; }}</li>"
  );

in env.lib.documentedTemplate {
  description = "Normal template for rendering a page as a list entry (`li` tag).";

  inherit env template;
}
