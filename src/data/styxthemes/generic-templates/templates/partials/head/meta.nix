env:

let template = env: page:
  ''
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  '';

in with env.lib; documentedTemplate {
  description = ''
    Generic `meta` tags, should be overriden to fit needs. +
    Default contents:

    +
    [source, html]
    ----
    ${template env {}}
    ----
  '';
  inherit env template;
}
