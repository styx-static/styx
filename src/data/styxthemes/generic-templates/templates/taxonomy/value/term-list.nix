/*
return a list of taxonomy terms data for a page in format:

  { path = ...; taxonomy = ...; term = ...; }
*/
env: let
  template = {
    lib,
    templates,
    ...
  }: {
    taxonomy,
    page,
  }:
    with lib.lib;
      optionals
      (hasAttr taxonomy page)
      map (term: {
        path = lib.pages.mkTaxonomyTermPath taxonomy term;
        inherit taxonomy term;
      })
      page."${taxonomy}";
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating a list of taxonomy terms data for a taxonomy value (page).
    '';
    arguments = {
      taxonomy = {
        description = "Taxonomy name.";
        type = "String";
      };
      page = {
        description = "Page attribute set.";
        type = "Page";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.taxonomy.value.term-list {
            taxonomy = "tags";
            page = {
              tags = [ "foo" "bar" ];
            };
          }
        '';
        code = with env;
          templates.taxonomy.value.term-list {
            taxonomy = "tags";
            page = {
              tags = ["foo" "bar"];
            };
          };
      })
    ];
    inherit env template;
  }
