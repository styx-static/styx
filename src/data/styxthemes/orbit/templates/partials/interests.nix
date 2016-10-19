{ conf, lib, ... }:
with lib;
optionalString (conf.theme.interests != null)
''
<div class="interests-container container-block">
  <h2 class="container-block-title">${conf.theme.interests.title}</h2>
  <ul class="list-unstyled interests-list">
  ${mapTemplate (item: ''
    <li>${item}</li>
  '') conf.theme.interests.items}
  </ul>
</div><!--//interests-->
''
