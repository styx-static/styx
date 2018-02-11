{ lib
, pkgs }:

{
  
  lib.data = {
    markup = {
      asciidoc = {
        command = lib.mkOption {
          default = f: "${pkgs.asciidoctor}/bin/asciidoctor -b xhtml5 -s -a showtitle -o- ${f} > $out";
          #type = types.lambda;
          description = "Command to convert asciidoc as a function that take the path of the file to convert as parameter.";
        };
        extensions = lib.mkOption {
          default = ["adoc" "asciidoc"];
          type = with lib.types; listOf str;
          description = "Supported extensions for asciidoctor files.";
        };
      };
      markdown = {
        command = lib.mkOption {
          default = f: "${pkgs.multimarkdown}/bin/multimarkdown ${f} > $out";
          #type = types.lambda;
          description = "Command to convert asciidoc as a function that take the path of the file to convert as parameter.";
        };
        extensions = lib.mkOption {
          default = ["md" "mdown" "markdown"];
          type = with lib.types; listOf str;
          description = "Supported extensions for markdown files.";
        };
      };
    };
    parser = {
      command = lib.mkOption {
        default = f: "${pkgs.python27.withPackages (ps: [ ps.parsimonious ])}/bin/python ${pkgs.styx}/share/styx/tools/parser.py < ${f} > $out";
        #type = types.lambda;
        description = "Command to convert asciidoc as a function that take the path of the file to convert as parameter.";
      };
    };
  };
}
