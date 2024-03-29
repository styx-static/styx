{
  conf,
  lib,
  ...
}: block:
with lib.lib; {
  content = ''
    <div class="languages-container container-block">
      <h2 class="container-block-title">${block.title}</h2>
      <ul class="list-unstyled interests-list">
      ${lib.template.mapTemplate (item: ''
        <li>${item.language} <span class="lang-desc">(${item.level})</span></li>
      '')
      block.items}
      </ul>
    </div><!--//languages-->
  '';
}
