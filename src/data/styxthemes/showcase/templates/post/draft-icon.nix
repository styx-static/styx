{
  lib,
  templates,
  ...
}: page:
with lib.lib; optionalString (page ? isDraft) (templates.icon.bootstrap "file")
