# utilities

lib:
with lib;

{

  /* Merge multiple configurations
  */
  mergeConfs = fold (conf: acc:
      recursiveUpdate conf acc
    ) {};

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

  /* Set default values to a list of attributes sets
  */
  setDefault = list: default:
    map (set: default // set) list;

}
