env:

let template = env: { taxonomy, term }: "/${taxonomy}/${term}/";

in with env.lib; documentedTemplate {
  description = ''
    Template generating the path of a taxonomy term page.
  '';
  arguments = {
    taxonomy = {
      description = "Taxonomy name.";
      type = "String";
    };
    term = {
      description = "Term name.";
      type = "String";
    };
  };
  examples = [ (mkExample {
    literalCode = ''
      templates.taxonomy.term.path { taxonomy = "tags"; term = "tech"; }
    '';
    code = with env;
      templates.taxonomy.term.path { taxonomy = "tags"; term = "tech"; }
    ;
  }) ];
  inherit env template;
}
