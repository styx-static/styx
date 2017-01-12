# utilities

lib:
with lib;

{

  /* Merge multiple sets
  */
  merge = fold (set: acc:
      recursiveUpdate set acc
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

  /* Check if a path exists in a dir
     
     Used to overcome pathExists limitations with store paths
  */
  dirContains = dir: path:
    let
      pathArray = filter (x: x != "") (splitString "/" path);
      loop = base: path:
        let contents = readDir base;
        in if hasAttrByPath [ (head path) ] contents
           then if length path > 1
                then loop (base + "/${head path}") (tail path)
                else true
           else false;
    in loop dir pathArray;


  /* Set default values to a list of attributes sets
  */
  setDefault = list: default:
    map (set: default // set) list;

}
