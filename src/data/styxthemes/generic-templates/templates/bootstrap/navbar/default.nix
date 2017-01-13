/* NavBar template, generate a navbar from data.navbar

templates.bootstrap.navbar.default {
  content = [
    (templates.bootstrap.navbar.nav {
      items = [ pages.about ];
      currentPage = page;
    })
    (templates.bootstrap.navbar.text {
      content = "Hello world";
      align = "right";
    })
  ];
}

*/
{ templates, lib, ... }:
{
  id ? "navbar"
  # use the inverted navbar
, inverted ? false
  # css classes of the navbar
, extraClasses ? []
  # contents of the brand
, brand ? templates.bootstrap.navbar.brand
  # contents of the navbar nav
, content ? []
}@args:

let
  baseClass = if inverted then "navbar-inverse" else "navbar-default";
  class = lib.htmlAttr "class" ([ "navbar" baseClass ] ++ extraClasses);
in
''
<nav ${class}>
<div class="container">
${templates.bootstrap.navbar.head { inherit id brand; }}
<div class="collapse navbar-collapse" id="${id}">
${lib.concatStringsSep "\n" content}
</div>
</div>
</nav>
''
