{ lib, conf, templates, ... }:
{ items
, align ? null
, currentPage ? null
, ... }:
with lib;
let
  extraClasses = optionalString (align != null) " navbar-${align}";
  isCurrent = item:
      (currentPage != null && currentPage ? breadcrumbs && item ? path
       && elem item.path (map (p: p.path) currentPage.breadcrumbs))
   || (currentPage != null && item ? path && currentPage.path == item.path);
in
''
<ul class="nav navbar-nav${extraClasses}">
${mapTemplate (item:
  let
    class = optionalString (isCurrent item) (" " + htmlAttr "class" "active");
    href  = htmlAttr "href" (if (item ? url) then item.url else templates.purl item);
    title = item.navbarTitle or item.title;
  in ''
  <li${class}><a ${href}>${title}</a></li>''
) items}
</ul>''
