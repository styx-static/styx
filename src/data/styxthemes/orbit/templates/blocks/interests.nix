{ conf, lib, ... }:
block:
with lib;
{
  content = ''
    <div class="interests-container container-block">
      <h2 class="container-block-title">${block.title}</h2>
      <ul class="list-unstyled interests-list">
      ${mapTemplate (item: ''
        <li>${item}</li>
      '') block.items}
      </ul>
    </div><!--//interests-->
  '';
}
