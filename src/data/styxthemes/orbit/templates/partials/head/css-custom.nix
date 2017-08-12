{ templates, conf, ... }:
page:
  templates.tag.link-css { href = templates.url "/assets/css/styles-${toString conf.theme.colorScheme}.css"; }
