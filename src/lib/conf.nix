# conf

lib:
with lib;

let
  isOptionType = x: isAttrs x && x ? _type && x._type == "option-type";
in rec {

  /* extract a key from a mkOption declaration
  */
  extract = { 
    key
  , set
  , nullify ? false
  }:
    let
      recurse = set:
        let
          g = name: value:
            if isOption value && hasAttr key value
            then getAttr key value
            # avoid infinite recusrion into types
            else if isAttrs value && ! (isOption value || isOptionType value)
                 then recurse value
                 else if nullify then null else value;
        in mapAttrs g set;
      result = recurse set;
  in recurse set;

  /* Type check configuration declaration (site conf.nix) with the configuration definition (theme conf.nix)
  */
  typeCheck = types: defs:
    #let
    #  types = extract "type" defs;
    #in 
    mapAttrsRecursive (path: v:
      if (hasAttrByPath path types) && isOptionType (getAttrFromPath path types)
      then if   (getAttrFromPath path types).check v
           then "check ok"
           else throw "The configuration option `theme.${showOption path}' is not a ${(getAttrFromPath path types).name}."
      else "no type"
    ) defs;

}
