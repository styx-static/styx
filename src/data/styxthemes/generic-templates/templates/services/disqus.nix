env:

let template = { conf, templates, lib, ... }:
  page:
  with lib;
  let
    id =
      if page ? disqusID
      then page.disqusID
      else if page ? rootPage
           then page.rootPage.path
           else page.path;
    cnf = conf.theme.services.disqus;
  in
  optionalString (cnf.shortname != null)
  ''
  <div id="disqus_thread"></div>
  <script>

  /**
  *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
  *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables*/
  var disqus_config = function () {
    this.page.identifier = "${id}";
    this.page.url = "${templates.url page}";
  };
  (function() { // DON'T EDIT BELOW THIS LINE
  var d = document, s = d.createElement('script');
  s.src = '//${cnf.shortname}.disqus.com/embed.js';
  s.setAttribute('data-timestamp', +new Date());
  (d.head || d.body).appendChild(s);
  })();
  </script>
  <noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
  '';

in with env.lib; documentedTemplate {
  description = ''
    Template managing link:https://disqus.com/[disqus] integration. +
    Before using disqus, `conf.theme.services.disqus.shortname` configuration option should be set. +
    Page unique identifier will be automatically generated, but can be set by adding a `disqusID` attribute to the page.
  '';
  examples = [ (mkExample {
    literalCode = ''
      templates.services.disqus page
    '';
  }) (mkExample {
    literalCode = ''
      templates.services.disqus (page // { disqusID = "main-thread"; })
    '';
  }) ];
  inherit env template;
}
