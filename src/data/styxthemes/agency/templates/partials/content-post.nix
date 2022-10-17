{
  lib,
  conf,
  templates,
  ...
}: args:
with lib.lib; ''
  <footer>
    <div class="container">
      <div class="row">
        <div class="col-md-4">
          <span class="copyright">${conf.theme.footer.copyright}</span>
        </div>
        <div class="col-md-4">
          <ul class="list-inline social-buttons">
            ${lib.template.mapTemplate (item: ''
      <li><a href="${item.link}"><i class="fa ${item.icon}"></i></a></li>
    '')
    conf.theme.footer.social}
          </ul>
        </div>
        <div class="col-md-4">
          <ul class="list-inline quicklinks">
            ${lib.template.mapTemplate (item: ''
      <li><a href="${item.link}">${item.text}</a></li>
    '')
    conf.theme.footer.quicklinks}
          </ul>
        </div>
      </div>
    </div>
  </footer>
''
