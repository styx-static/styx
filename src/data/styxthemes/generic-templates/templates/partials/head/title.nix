{ lib, conf, ... }:
{ page, ... }:
''
<title>${page.title}${lib.optionalString (lib.hasAttrByPath ["theme" "site" "title"] conf) " - ${conf.theme.site.title}"}</title>
''
