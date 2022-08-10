{ lib
, pkgs }:

{
  
  lib.data = {
    markup = {
      asciidoc = {
        extensions = lib.mkOption {
          default = ["adoc" "asciidoc"];
          type = with lib.types; listOf str;
          description = "Supported extensions for asciidoctor files.";
        };
        converter = lib.mkOption {
          default = f: "${pkgs.asciidoctor}/bin/asciidoctor -b xhtml5 -s -a showtitle -o- ${f} > $out";
          type = with lib.types; functionTo str;
          description = "Command to convert asciidoc as a function that take the path of the file to convert as parameter.";
        };
        parser = lib.mkOption {
          default = f: "${pkgs.python310.withPackages (ps: [ ps.parsimonious ])}/bin/python ${pkgs.styx}/share/styx/tools/asciidoc-parser.py < ${f} > $out";
          type = with lib.types; functionTo str;
          description = "Command to parse asciidoc to a styx page attribute set as a function that take the path of the file to parse as parameter.";
        };
      };
      markdown = {
        extensions = lib.mkOption {
          default = ["md" "mdown" "markdown"];
          type = with lib.types; listOf str;
          description = "Supported extensions for markdown files.";
        };
        converter = lib.mkOption {
          default = f: "${pkgs.multimarkdown}/bin/multimarkdown ${f} > $out";
          type = with lib.types; functionTo str;
          description = "Command to convert asciidoc as a function that take the path of the file to convert as parameter.";
        };
        parser = lib.mkOption {
          default = f: "${pkgs.python310.withPackages (ps: [ ps.parsimonious ])}/bin/python ${pkgs.styx}/share/styx/tools/markdown-parser.py < ${f} > $out";
          type = with lib.types; functionTo str;
          description = "Command to parse asciidoc to a styx page attribute set as a function that take the path of the file to parse as parameter.";
        };
      };
    };
  };
}
