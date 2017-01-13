{ lib, ... }:
{ content
, extraClasses ? []
, align ? null
, ... }:
let
  alignClass = lib.optional (align == "right" || align == "left") "navbar-${align}";
  class = lib.htmlAttr "class" ([ "navbar" ] ++ alignClass ++ extraClasses);
''
<p ${class}>${content}</p>
''
