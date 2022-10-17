env: let
  template = {
    lib,
    templates,
    ...
  }:
    lib.template.normalTemplate (page: rec {
      title = page.title or page.taxonomy;
      content = ''
        <h1>${title}</h1>
        <ul>
        ${lib.template.mapTemplate (
          t: ''
            <li>${templates.tag.ilink {
              to = t.path;
              content = t.term;
            }} (${toString t.count})</li>''
        ) (templates.taxonomy.term-list page.taxonomyData)}
        </ul>
      '';
    });
in
  env.lib.template.documentedTemplate {
    description = ''
      Template displaying a taxonomy information.
    '';
    arguments = {
      page = {
        description = "Taxonomy page generated with `mkTaxonomyPages` function.";
        type = "page";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          pages.taxonomies = lib.data.mkTaxonomyPages {
            data             = data.taxonomies.posts;
            taxonomyTemplate = templates.taxonomy.full;
            termTemplate     = templates.taxonomy.term.full;
          };
        '';
      })
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.taxonomy.full (lib.proplist.getProp "tags" (lib.data.mkTaxonomyData {
            data = [
              { tags = [ "foo" "bar" ]; path = "/a.html"; }
              { tags = [ "foo" ];       path = "/b.html"; }
              { category = [ "baz" ];   path = "/c.html"; }
            ];
            taxonomies = [ "tags" "category" ];
          }))
        '';
        code = with env;
          (
            templates.taxonomy.full {
              taxonomy = "tags";
              taxonomyData = lib.proplist.getProp "tags" (lib.data.mkTaxonomyData {
                data = [
                  {
                    tags = ["foo" "bar"];
                    path = "/a.html";
                  }
                  {
                    tags = ["foo"];
                    path = "/b.html";
                  }
                  {
                    category = ["baz"];
                    path = "/c.html";
                  }
                ];
                taxonomies = ["tags" "category"];
              });
            }
          )
          .content;
      })
    ];
    inherit env template;
  }
