env:

let template = { templates, lib, ... }:
  { user, width ? null, height ? null }:
  with lib;
  let
    dataWidth  = optionalString (width  != null) (" " + htmlAttr "data-width"  (toString width));
    dataHeight = optionalString (height != null) (" " + htmlAttr "data-height" (toString height));
  in
  ''<a class="twitter-timeline"${dataWidth + dataHeight} href="https://twitter.com/${user}">Tweets by ${user}</a>
    <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script> 
  ''
  ;

in env.lib.documentedTemplate {
  description = "Template to embed a twitter timeline.";

  arguments = {
    user = {
      description = "Twitter user.";
      type = "String";
    };
    height = {
      description = "Embedded timeline height.";
      type = "Int";
    };
    width = {
      description = "Embedded timeline width.";
      type = "Int";
    };
  };

  inherit env template;
}

