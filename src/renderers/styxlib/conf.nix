{
  l,
  styxlib,
}: let
  inherit (styxlib) utils;
in {
  /*
  ===============================================================

   parseDecls

  ===============================================================
  */
  parseDecls = utils.documentedFunction {
    description = ''
      Parse configuration interface declarations.
    '';

    arguments = {
      decls = {
        description = "A configuration attribute set.";
        type = "Attrs";
      };
      optionFn = {
        description = "Function to convert options.";
        type = "Option -> a";
        default = l.literalExpression "l.id";
      };
      valueFn = {
        description = "Function to convert values.";
        type = "a -> b";
        default = l.literalExpression "l.id";
      };
    };

    return = "`Attrs`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.conf.parseDecls {
            optionFn = o: option.default;
            valueFn  = v: v + 1;
            decls = {
              a.b.c = l.mkOption {
                default = "abc";
                type = l.types.str;
              };
              x.y = 1;
            };
          }
        '';
        code = styxlib.conf.parseDecls {
          optionFn = option: option.default;
          valueFn = v: v + 1;
          decls = {
            a.b.c = l.mkOption {
              default = "abc";
              type = l.types.str;
            };
            x.y = 1;
          };
        };
        expected = {
          a.b.c = "abc";
          x.y = 2;
        };
      })
    ];

    function = {
      decls,
      optionFn ? l.id,
      valueFn ? l.id,
    }: let
      recurse = set: let
        g = name: value:
          if l.isOption value
          then optionFn value
          else if l.isAttrs value
          then recurse value
          else valueFn value;
      in
        l.mapAttrs g set;
    in
      recurse decls;
  };

  /*
  ===============================================================

   mergeConfs

  ===============================================================
  */

  mergeConfs = utils.documentedFunction {
    description = ''
      Merge a list of configurations.
    '';

    arguments = [
      {
        name = "confs";
        description = "List of configurations.";
        type = "[ Attrs | Path ]";
      }
    ];

    return = ''
      The merged configuration set.
    '';

    function = confs:
      utils.merge (map (c:
        if utils.isPath c
        then utils.importApply c {inherit l styxlib;}
        else c)
      confs);
  };

  /*
  ===============================================================

   typeCheck

  ===============================================================
  */

  typeCheck = utils.documentedFunction {
    description = ''
      Type check configuration declarations against definitions.
    '';

    arguments = [
      {
        name = "decls";
        description = "A configuration declarations attribute set.";
        type = "Attrs";
      }
      {
        name = "defs";
        description = "A configuration definitions attribute set.";
        type = "Attrs";
      }
    ];

    return = ''
      Throw an error if `defs` do not type-check with `decls`.
    '';

    function = decls: defs:
      l.mapAttrsRecursive (
        path: def: let
          type = l.attrByPath (path ++ ["type"]) null decls;
        in
          if l.isOptionType type
          then
            if type.check def
            then "check ok"
            else throw "The configuration option `theme.${l.showOption path}' is not a ${type.description}."
          else "no type"
      )
      defs;
  };
}
