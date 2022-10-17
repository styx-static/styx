{
  lib,
  templates,
  ...
}:
lib.template.normalTemplate (page: lib.template.processBlocks page.blocks)
