{ conf, ... }:
''
  <footer>
    <div class="container wrapper">
      <div class="row">
        <div class="col-sm-4 col-xs-4">
          <p>${conf.theme.site.copyright}</p>
        </div>
        <div class="col-sm-4 col-xs-4">
          <ul class="list-unstyled">
            <li><a href="https://nixos.org/nix/">Nix</a></li>
          </ul>
        </div>
        <div class="col-sm-4 col-xs-4">
          <p>${conf.theme.site.description}</p>
        </div>
      </div>
    </div>
  </footer>

''
