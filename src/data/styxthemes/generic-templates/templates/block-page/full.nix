{ lib, templates, ... }:
with lib;
normalTemplate (page:
  processBlocks page.blocks
)
