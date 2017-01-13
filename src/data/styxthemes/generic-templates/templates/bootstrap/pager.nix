{ lib, conf, templates, ... }:
{ pages, index }:
with lib;
let
  prevHref = if (index > 1)
             then templates.purl (elemAt pages (index - 2))
             else "#";
  nextHref = if (index < (length pages))
             then templates.purl (elemAt pages index)
             else "#";
in
''
<nav aria-label="...">
<ul class="pager">
<li${optionalString (index == 1) " ${htmlAttr "class" "disabled"}"}><a ${htmlAttr "href" prevHref}>Previous</a></li>
<li${optionalString (index == (length pages)) " ${htmlAttr "class" "disabled"}"}><a ${htmlAttr "href" nextHref}>Next</a></li>
</ul>
</nav>
''
