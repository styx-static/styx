# utilities

lib:
with lib;

let
  documentedFunction' = data: arg: 
    if arg == { _type = "genDoc"; }
    then (data // { _type = "docFunction"; })
    else data.function arg;

  is = type: x: isAttrs x && x ? _type && x._type == type;

in rec {

  _documentation = _: ''
    This namespace contains generic functions.
  '';

# -----------------------------

  isDocTemplate = documentedFunction {
    description = "Check if a set is a documented template.";

    arguments = [
      {
        name = "set";
        description = "Attribute set to check.";
        type = "Attrs";
      }
    ];

    return = "`Bool`";

    function = is "docTemplate";
  };

# -----------------------------

  isExample = documentedFunction {
    description = "Check if a set is an example.";

    function = is "example";
  };

# -----------------------------

  isDocFunction = documentedFunction {
    description = "Check if a set is a documented fuction.";

    function = is "docFunction";
  };

# -----------------------------

  mkExample = documentedFunction {
    description = "Create an example set.";

    return = "An example attribute set.";

    function = {
      literalCode ? null
    , code ? null
    , expected ? null
    }@args:
    args // { _type = "example"; };
  };

# -----------------------------

  documentedFunction = documentedFunction' {
    description = "Create a documented function.";

    function = data: arg: 
      if arg == { _type = "genDoc"; }
      then (data // { _type = "docFunction"; })
      else data.function arg;
  };

# -----------------------------

  chunksOf = documentedFunction {
    description = "Split a list in lists multiple lists of `size` items.";

    arguments = [
      {
        name = "size";
        description = "Maximum size of the splitted lists.";
        type = "Integer";
      }
      {
        name = "list";
        description = "List to split.";
        type = "List";
      }
    ];

    return = ''
      A list of lists of `size` size.
    '';

    examples = [ (mkExample {
      literalCode = "chunksOf 2 [ 1 2 3 4 5 ]";
      code        = chunksOf 2 [ 1 2 3 4 5 ];
      expected    = [ [ 1 2 ] [ 3 4 ] [ 5 ] ];
    })];

    function = k:
      let f = ys: xs:
            if xs == []
            then ys
            else f (ys ++ [(take k xs)]) (drop k xs);
      in f [];
  };

# -----------------------------

  merge = documentedFunction {
    description = "Merge recursively a list of sets.";

    examples = [ (mkExample {
      literalCode = ''
        conf = lib.utils.merge [
          (lib.themes.loadConf { inherit themes; })
          (import ./conf.nix)
          extraConf
        ];
      '';
    }) (mkExample {
      literalCode = ''
        merge [ { a = 1; b = 2; } { b = "x"; c = "y"; } ]
      '';
      code =
        merge [ { a = 1; b = 2; } { b = "x"; c = "y"; } ]
      ;
      expected = { a = 1; b = "x"; c = "y"; };
    })];

    function = foldl' (set: acc:
        recursiveUpdate set acc
      ) {};
  };

# -----------------------------

  sortBy = documentedFunction {
    description = "Sort a list of attribute sets by attribute.";

    examples = [ (mkExample {
      literalCode = ''
        sortBy "priority" "asc" [ { priority = 5; } { priority = 2; } ]
      '';
      code =
        sortBy "priority" "asc" [ { priority = 5; } { priority = 2; } ]
      ;
      expected = [ { priority = 2; } { priority = 5; } ];
    })];

    function = attribute: order: 
      sort (a: b: 
             if order == "asc" then a."${attribute}" < b."${attribute}"
        else if order == "dsc" then a."${attribute}" > b."${attribute}"
        else    abort "Sort order must be 'asc' or 'dsc'");
  };

# -----------------------------

  dirContains = documentedFunction {
    description = "Check if a path exists in a directory.";

    function = dir: path:
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
  };

# -----------------------------

  setToList = documentedFunction {
    description = "Convert a deep set to a list of sets where the key is the path.";

    examples = [ (mkExample {
      literalCode = ''
        setToList { a.b.c = true; d = "foo"; x.y.z = [ 1 2 3 ]; }
      '';
      code =
        setToList { a.b.c = true; d = "foo"; x.y.z = [ 1 2 3 ]; }
      ;
      expected = [ { "a.b.c" = true; } { d = "foo"; } { "x.y.z" = [ 1 2 3 ]; } ];
    }) ];

    function = s:
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
  };

# -----------------------------

  importApply = documentedFunction {
    description = "Import a nix file `file` and apply the arguments `args` if it is a function.";

    function = file: arg:
      let f = import file;
      in if isFunction f then f arg else f;
  };

# -----------------------------

  prettyNix = documentedFunction {
    description = "Pretty print nix values.";

    examples = [ (mkExample {
      literalCode = ''
        prettyNix [ { a.b.c = true; } { x.y.z = [ 1 2 3 ]; } ]
      '';
      code =
        prettyNix [ { a.b.c = true; } "foo" { x.y.z = [ 1 2 3 ]; } ]
      ;
    }) ];

    function = expr:
      let indent = n: concatStrings (genList (x: " ") (n*2));
          isLit = x: isAttrs x && x ? _type && x._type == "literalExample";
          loop   = n: x:
             if isString x then ''"${replaceStrings [''"''] [''\"''] x}"''
        else if isInt    x then toString x
        else if isNull   x then "null"
        else if isList   x then ''[ ${concatStringsSep " " (map (loop n) x)} ]''
        else if isBool   x then toJSON x
        else if x == {}    then ''{ }''
        else if isLit    x then x.text
        else if isAttrs  x then ''
        {
        ${indent (n+1)}${concatStringsSep "\n${indent (n+1)}" (mapAttrsToList (k: v: "${k} = ${loop (n+1) v};") x)}
        ${indent n}}''
        else if isFunction x then ''<LAMBDA>''
        else "";
      in loop 0 expr;
  };
}
