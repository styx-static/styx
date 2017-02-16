env:

let template = { lib, conf, ... }:
  with lib;
  optionalString (conf.theme.services.google-analytics.trackingID != null) ''
  <script>
    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
    })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
  
    ga('create', '${conf.theme.service.google-analytic.trackingID}', 'auto');
    ga('send', 'pageview');
  
  </script>
  '';

in with env.lib; documentedTemplate {
  description = "Template managing link:https://www.google.com/analytics/[google analytics] integration. Controlled with `conf.theme.services.google-analytics.trackingID` configuration option.";
  inherit env template;
}
