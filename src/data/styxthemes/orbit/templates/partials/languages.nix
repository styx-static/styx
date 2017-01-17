{ conf, lib, ... }:
with lib;
optionalString (conf.theme.languages.items != [])
''
<div class="languages-container container-block">
  <h2 class="container-block-title">${conf.theme.languages.title}</h2>
  <ul class="list-unstyled interests-list">
  ${mapTemplate (item: ''
    <li>${item.language} <span class="lang-desc">(${item.level})</span></li>
  '') conf.theme.languages.items}
  </ul>
</div><!--//languages-->
''
