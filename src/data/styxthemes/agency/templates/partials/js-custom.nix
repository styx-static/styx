{ templates, ... }:
page:
  templates.tag.script { src = templates.url "/js/classie.js"; }
+ templates.tag.script { src = "https://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.4.1/jquery.easing.js"; }
+ templates.tag.script { src = templates.url "/js/cbpAnimatedHeader.js"; }
+ templates.tag.script { src = templates.url "/js/agency.js"; }
