{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.app) parsers;

  l = nixpkgs.lib // builtins;
in {
  lib.data = {
    markup = {
      asciidoc = {
        extensions = l.mkOption {
          default = ["adoc" "asciidoc"];
          type = with l.types; listOf str;
          description = "Supported extensions for asciidoctor files.";
        };
        converter = l.mkOption {
          default = f: "${l.getExe nixpkgs.asciidoctor} -b xhtml5 -s -a showtitle -o- ${f} > $out";
          type = with l.types; functionTo str;
          description = "Command to convert asciidoc as a function that take the path of the file to convert as parameter.";
        };
        parser = l.mkOption {
          default = f: "${l.getExe parsers.asciidoc} < ${f} > $out";
          type = with l.types; functionTo str;
          description = "Command to parse asciidoc to a styx page attribute set as a function that take the path of the file to parse as parameter.";
        };
      };
      markdown = {
        extensions = l.mkOption {
          default = ["md" "mdown" "markdown"];
          type = with l.types; listOf str;
          description = "Supported extensions for markdown files.";
        };
        converter = l.mkOption {
          default = f: "${l.getExe nixpkgs.pandoc} ${f} > $out";
          type = with l.types; functionTo str;
          description = "Command to convert markdown as a function that take the path of the file to convert as parameter.";
        };
        parser = l.mkOption {
          default = f: "${l.getExe parsers.markdown} < ${f} > $out";
          type = with l.types; functionTo str;
          description = "Command to parse markdown to a styx page attribute set as a function that take the path of the file to parse as parameter.";
        };
      };
    };
  };
}
