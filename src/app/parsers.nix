{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  l = nixpkgs.lib // builtins;

  inherit (nixpkgs.python3Packages) parsimonious;
  inherit (nixpkgs.writers) writePython3Bin;
in {
  asciidoc = let
    drv = writePython3Bin "asciidoc-parser" {libraries = [parsimonious];} (l.readFile ./parsers/asciidoc.py);
  in
    drv // {meta = drv.meta // {description = "Asciidoc parser for Styx";};};
  markdown = let
    drv = writePython3Bin "markdown-parser" {libraries = [parsimonious];} (l.readFile ./parsers/markdown.py);
  in
    drv // {meta = drv.meta // {description = "Markdown parser for Styx";};};
}
