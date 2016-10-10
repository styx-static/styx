{ conf, ... }:
''
  <footer>
    <div class="container wrapper">
      <div class="row">
        <div class="col-sm-4 col-xs-4">
          <p>${conf.siteTitle}</p>
        </div>
        <div class="col-sm-4 col-xs-4">
          <ul class="list-unstyled">
            <li><a href="https://nixos.org/nix/">Nix</a></li>
          </ul>
        </div>
        <div class="col-sm-4 col-xs-4">
          <p>${conf.siteDescription}</p>
        </div>
      </div>
    </div>
  </footer>
''
