# utilities

lib:
with lib;

{

  /* Override the conf attribute set with an attribute set.
     Update is recursive and only keys with a non-null value are updated.
  */
  overrideConf = conf: override:
    conf // (filterAttrs (k: v: (hasAttr k conf) && (v != null)) override);

  /* split a list in multiple lists of k size
  */
  chunksOf = k:
    let f = ys: xs:
        if xs == []
           then ys
           else f (ys ++ [(take k xs)]) (drop k xs);
    in f [];

  /* Sort a list attribute sets by an attribute value
  */
  sortBy = attribute: order: 
    sort (a: b: 
           if order == "asc" then a."${attribute}" < b."${attribute}"
      else if order == "dsc" then a."${attribute}" > b."${attribute}"
      else    abort "Sort order must be 'asc' or 'dsc'");

}
