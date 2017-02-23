env:

let template = { lib, conf, ... }:
  with lib;
  let
    cnf = conf.theme.services.piwik;
  in optionalString cnf.enable ''
  <!-- Piwik -->
  <script type="text/javascript">
    var _paq = _paq || [];
    _paq.push(['trackPageView']);
    _paq.push(['enableLinkTracking']);
    (function() {
      var u="${cnf.url}";
      _paq.push(['setTrackerUrl', u+'piwik.php']);
      _paq.push(['setSiteId', '${cnf.IDsite}']);
      var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
      g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
    })();
  </script>
  <!-- End Piwik Code -->
  '';

in with env.lib; documentedTemplate {
  description = "Template managing link:https://piwik.org/[Piwik] integration. Controlled with `conf.theme.services.piwik.*` configuration options.";
  inherit env template;
}
