{ lib, ... }:
data: 
with lib;
let
  class = optionalString (data ? class) " ${htmlAttr "class" data.class}";
in ''
${data.pre or ""}
<section id="${data.id}"${class}>
  <div class="container">
    ${optionalString ((data ? title) || (data ? subtitle)) ''
    <div class="row">
      <div class="col-lg-12 text-center">
        ${optionalString (data ? title)    ''<h2 class="section-heading">${data.title}</h2>''}
        ${optionalString (data ? subtitle) ''<h3 class="section-subheading text-muted">${data.subtitle}</h3>''}
      </div>
    </div>
    ''}
    ${data.content or ""}
  </div>
</section>
${data.post or ""}
''
