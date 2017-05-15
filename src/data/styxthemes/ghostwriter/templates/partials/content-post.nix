{ conf, templates, ... }:
args:
''
  </div>
  <footer class="footer">
    <div class="container">
      <div class="site-title-wrapper">
        <h1 class="site-title">
            <a title="${conf.theme.site.title}" href="${templates.url "/"}">${conf.theme.site.title}</a>
        </h1>
        <a class="button-square button-jump-top js-jump-top" href="#">
            <i class="fa fa-angle-up"></i>
        </a>
      </div>

      <p class="footer-copyright">
          <span>${conf.theme.site.copyright}</span>
      </p>
      <p class="footer-copyright">
          <span><a href="https://github.com/roryg/ghostwriter">Ghostwriter theme</a> By <a href="http://jollygoodthemes.com">JollyGoodThemes</a></span>
      </p>
    </div>
  </footer>
''
