{ templates, ... }:
attrs:
templates.tag.link ({ rel = "alternate"; type = "application/atom+xml"; } // attrs)
