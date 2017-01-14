{ lib, templates, ... }:
page:
lib.optionalString (page ? isDraft) (templates.icon.bootstrap "file")
