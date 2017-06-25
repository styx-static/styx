env:

let template = env:
  { brand
  , id }:
  ''
  <div class="navbar-header">
    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#${id}-collapse" aria-expanded="false">
      <span class="sr-only">Toggle navigation</span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
      <span class="icon-bar"></span>
    </button>
    ${brand}
  </div>'';

in env.lib.documentedTemplate {
  description = "Template used by `bootstrap.navbar.default`, not meant to be used directly.";
  inherit env template;
}
