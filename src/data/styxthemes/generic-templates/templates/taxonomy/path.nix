env:

let template = env: taxonomy: "/${taxonomy}/";

in with env.lib; documentedTemplate {
  description = ''
    Template generating the path of a taxonomy page.
  '';
  arguments = [
    {
      name = "taxonomy";
      description = "Taxonomy name.";
      type = "String";
    }
  ];
  examples = [ (mkExample {
    literalCode = ''
      templates.taxonomy.path "tags"
    '';
    code = with env;
      templates.taxonomy.path "tags"
    ;
  }) ];
  inherit env template;
}
