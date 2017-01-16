# utilities

lib:
with lib;

{

  /* Merge multiple sets
  */
  merge = foldl' (set: acc:
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

  /* Convert a deep set to a list of sets where the key is the path
     Used to prepare substitutions
  */
  setToList = s:
    let
    f = path: set:
      map (key:
        let
          value = set.${key};
          newPath = path ++ [ key ];
          pathString = concatStringsSep "." newPath;
        in
        if isAttrs value
           then f newPath value
           else { "${pathString}" = value; }
      ) (attrNames set);
    in flatten (f [] s);

  /* import a file and if it is a function load apply args to it
  */
  importApply = file: arg:
    let f = import file;
    in if isFunction f then f arg else f;

  /* Set default values to a list of attributes sets
  */
  setDefault = list: default:
    map (set: default // set) list;

}
