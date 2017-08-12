{ templates, ... }:
page:
  templates.tag.script { src = "https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"; }
+ templates.tag.script { src = "https://oss.maxcdn.com/respond/1.4.2/respond.min.js"; }
+ templates.tag.script { src = templates.url "/assets/js/main.js"; }
