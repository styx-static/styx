# conf

{lib, ...}@args:
with lib;
with (import ./utils.nix args);

rec {

/*
===============================================================

 parseDecls

===============================================================
*/
  parseDecls = documentedFunction {

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
        default = literalExpression "lib.id";
      };
      valueFn = {
        description = "Function to convert values.";
        type = "a -> b";
        default = literalExpression "lib.id";
      };
    };

    return = "`Attrs`";

    examples = [ (mkExample {
      literalCode = ''
        parseDecls {
          optionFn = o: option.default;
          valueFn  = v: v + 1;
          decls = {
            a.b.c = mkOption {
              default = "abc";
              type = types.str;
            };
            x.y = 1;
          };
        }
      '';
      code =
        parseDecls {
          optionFn = option: option.default;
          valueFn  = v: v + 1;
          decls = {
            a.b.c = mkOption {
              default = "abc";
              type = types.str;
            };
            x.y = 1;
          };
        }
      ;
      expected = { a.b.c = "abc"; x.y = 2; };
    }) ];

    function = {
        decls
      , optionFn ? id
      , valueFn  ? id
      }:
        let
          recurse = set:
            let
              g = name: value:
                if isOption value then optionFn value
                else if isAttrs value
                     then recurse value
                     else valueFn value;
            in mapAttrs g set;
          result = recurse set;
      in recurse decls;

  };

/*
===============================================================

 mergeConfs

===============================================================
*/

  mergeConfs = documentedFunction {

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
      merge (map (c: if isPath c then importApply c args else c) confs);

  };


/*
===============================================================

 typeCheck

===============================================================
*/

  typeCheck = documentedFunction {

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
      mapAttrsRecursive (path: def:
        let type = attrByPath (path ++ ["type"]) null decls;
        in
        if isOptionType type
        then if   type.check def
             then "check ok"
             else throw "The configuration option `theme.${showOption path}' is not a ${type.description}."
        else "no type"
      ) defs;

  };

}
