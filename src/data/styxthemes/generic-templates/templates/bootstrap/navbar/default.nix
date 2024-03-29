env: let
  template = {
    templates,
    lib,
    ...
  }:
    with lib.lib;
      {
        id ? "navbar",
        inverted ? false,
        fluid ? false,
        extraClasses ? [],
        brand ? templates.bootstrap.navbar.brand,
        content ? [],
      } @ args: let
        baseClass =
          if inverted
          then "navbar-inverse"
          else "navbar-default";
        class = lib.template.htmlAttr "class" (["navbar" baseClass] ++ extraClasses);
      in ''
        <nav ${class} id="${id}">
        <div class="container${optionalString fluid "-fluid"}">
        ${templates.bootstrap.navbar.head {inherit id brand;}}
        <div class="collapse navbar-collapse" id="${id}-collapse">
        ${concatStringsSep "\n" content}
        </div>
        </div>
        </nav>
      '';
in
  env.lib.template.documentedTemplate {
    description = "Generates a navbar.";
    arguments = {
      id = {
        description = "HTML `id` used by the navbar.";
        type = "String";
        default = "navbar";
      };
      inverted = {
        description = "Whether to make navbar inverted.";
        type = "Boolean";
        default = false;
      };
      extraClasses = {
        description = "Extra CSS classes to add to the navbar.";
        default = [];
        type = "[ String ]";
      };
      brand = {
        description = "HTML code of the brand section.";
        default = env.lib.lib.literalExpression "templates.bootstrap.navbar.brand";
        type = "String";
      };
      content = {
        description = "Content of the navbar, usually a list of `templates.bootstrap.navbar.*` templates calls.";
        type = "String";
      };
    };
    examples = [
      (env.lib.utils.mkExample {
        literalCode = ''
          templates.bootstrap.navbar.default {
            inverted = true;
            brand = '''<a class="navbar-brand" href="#">Project Name</a>''';
            content = [
              (templates.bootstrap.navbar.nav {
                items = [
                  { title = "Home";    path = "/#"; }
                  { title = "About";   path = "/#about"; }
                  { title = "Contact"; path = "/#contact"; }
                ];
                currentPage = { title = "Home"; path = "/#"; };
              })
            ];
          }
        '';
        code = with env;
          templates.bootstrap.navbar.default {
            inverted = true;
            brand = ''<a class="navbar-brand" href="#">Project Name</a>'';
            content = [
              (templates.bootstrap.navbar.nav {
                items = [
                  {
                    title = "Home";
                    path = "/#";
                  }
                  {
                    title = "About";
                    path = "/#about";
                  }
                  {
                    title = "Contact";
                    path = "/#contact";
                  }
                ];
                currentPage = {
                  title = "Home";
                  path = "/#";
                };
              })
            ];
          };
      })
    ];
    inherit env template;
  }
