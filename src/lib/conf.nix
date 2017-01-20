# conf

lib:
with lib;

rec {

  parseDecls = {
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

  /* Type check configuration declaration (site conf.nix) with the configuration definition (theme conf.nix)
  */
  typeCheck = decls: defs:
    mapAttrsRecursive (path: v:
      let type = attrByPath (path ++ ["type"]) null decls;
      in
      if isOptionType type
      then if   type.check v
           then "check ok"
           else throw "The configuration option `theme.${showOption path}' is not a ${type.description}."
      else "no type"
    ) defs;

}
