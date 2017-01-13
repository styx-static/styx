{ lib, pages, templates, ... }:
args:
lib.optionalString (pages ? feed) 
  (templates.tag.link-atom {
    href = templates.purl pages.feed;
  })
