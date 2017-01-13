{ templates, ... }:
page:
  templates.partials.doctype
+ templates.partials.html { inherit page; }
