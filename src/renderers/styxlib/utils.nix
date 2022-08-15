{
  l,
  styxlib,
}: let
  inherit (styxlib) utils;
  documentedFunction' = data:
    data
    // {
      _type = "docFunction";
      __functor = _: data.function;
    };
in {
  _documentation = _: ''
    This namespace contains generic functions.
  '';

  /*
  ===============================================================

   find

  ===============================================================
  */

  find = utils.documentedFunction {
    description = "Find a set in a list of set matching some criteria.";

    arguments = [
      {
        name = "criteria";
        description = "Criteria to find as an attribute set, can be a value to be compared or a function to compare the value.";
        type = "Attrs";
      }
      {
        name = "list";
        description = "List of attributes to lookup for `criteria`.";
        type = "Attrs";
      }
    ];

    return = "The first matched attribute set, or throw an error if no result has been found.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.find { uid = "bar"; } [
            { uid = "foo"; }
            { uid = "bar"; content = "hello!"; }
            { uid = "baz"; }
          ]
        '';
        code = styxlib.utils.find {uid = "bar";} [
          {uid = "foo";}
          {
            uid = "bar";
            content = "hello!";
          }
          {uid = "baz";}
        ];
        expected = {
          uid = "bar";
          content = "hello!";
        };
      })
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.find { number = (x: x > 3); color = "blue"; } [
            { number = 1; color = "blue"; }
            { number = 4; color = "red"; }
            { number = 6; color = "blue"; }
          ]
        '';
        code =
          styxlib.utils.find {
            number = x: x > 3;
            color = "blue";
          } [
            {
              number = 1;
              color = "blue";
            }
            {
              number = 4;
              color = "red";
            }
            {
              number = 6;
              color = "blue";
            }
          ];
        expected = {
          number = 6;
          color = "blue";
        };
      })
    ];

    function = criteria: list: let
      subset = sub: super:
        l.fold (a: b: a && b) true (
          l.mapAttrsToList (
            k: v: let
              v' = l.getAttr k super;
              matching =
                if l.isFunction v
                then v v'
                else v == v';
            in
              l.hasAttr k super && matching
          )
          sub
        );
      matches = l.filter (x: subset criteria x) list;
    in
      if matches == []
      then
        throw ''
          No items matched the following find criteria:
          ---
          ${utils.prettyNix criteria}
          ---
        ''
      else l.head matches;
  };

  /*
  ===============================================================

   is

  ===============================================================
  */

  is = utils.documentedFunction {
    description = "Check if an attribute set has a certain type.";

    arguments = [
      {
        name = "type";
        description = "Type to check.";
        type = "String";
      }
      {
        name = "attrs";
        description = "Attribute set to check.";
        type = "Attrs";
      }
    ];

    return = "`Bool`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.is "foo" { _type = "foo"; }
        '';
        code =
          styxlib.utils.is "foo" {_type = "foo";};
        expected = true;
      })
    ];

    function = type: x: l.isAttrs x && x ? _type && x._type == type;
  };

  /*
  ===============================================================

   isExample

  ===============================================================
  */

  isExample = utils.documentedFunction {
    description = "Check if a set is an example.";

    arguments = [
      {
        name = "attrs";
        description = "Attribute set to check.";
        type = "Attrs";
      }
    ];

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.isExample (utils.mkExample {
            literalCode = "2 + 2";
            code = 2 + 2;
          })
        '';
        code = styxlib.utils.isExample (utils.mkExample {
          literalCode = "2 + 2";
          code = 2 + 2;
        });
        expected = true;
      })
    ];

    function = utils.is "example";
  };

  /*
  ===============================================================

   isDocExample

  ===============================================================
  */

  isDocFunction = utils.documentedFunction {
    description = "Check if a set is a documented fuction.";

    arguments = [
      {
        name = "attrs";
        description = "Attribute set to check.";
        type = "Attrs";
      }
    ];

    return = "`Bool`";

    function = utils.is "docFunction";
  };

  /*
  ===============================================================

   mkExample

  ===============================================================
  */

  mkExample = utils.documentedFunction {
    description = "Create an example set.";

    return = "An example attribute set.";

    function = {
      literalCode ? null,
      code ? null,
      displayCode ? l.id,
      expected ? null,
    } @ args:
      args
      // {
        _type = "example";
        inherit displayCode;
      };
  };

  /*
  ===============================================================

   documentedFunction

  ===============================================================
  */

  documentedFunction = documentedFunction' {
    description = "Create a documented function. A documented function is used to automatically generate documentation and tests.";

    arguments = {
      function = {
        description = "The function to document.";
      };
      description = {
        description = "Function description, asciidoc markup can be used.";
        type = "String";
      };
      arguments = {
        description = "Function arguments documentation. Attrs if the arguments are an attribute set, List for standard arguments.";
        type = "Null | Attrs | List";
        default = null;
      };
      examples = {
        description = "Examples of usages defined with `mkExample`.";
        type = "Null | [ Example ]";
      };
      return = {
        description = "Description of function return value, asciidoc markup can be used.";
        type = "String";
      };
      notes = {
        description = "Notes regarding special usages, asciidoc markup can be used.";
        type = "Null | String";
        default = "Null";
      };
    };

    return = "The documented function set.";

    function = {
      description,
      function,
      arguments ? null,
      return ? null,
      examples ? [],
      notes ? null,
    } @ data:
      data
      // {
        _type = "docFunction";
        __functor = self: self.function;
      };
  };

  /*
  ===============================================================

   chunksOf

  ===============================================================
  */

  chunksOf = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = "styxlib.utils.chunksOf 2 [ 1 2 3 4 5 ]";
        code = styxlib.utils.chunksOf 2 [1 2 3 4 5];
        expected = [[1 2] [3 4] [5]];
      })
    ];

    function = k: let
      f = ys: xs:
        if xs == []
        then ys
        else f (ys ++ [(l.take k xs)]) (l.drop k xs);
    in
      f [];
  };

  /*
  ===============================================================

   merge

  ===============================================================
  */

  merge = utils.documentedFunction {
    description = "Merge recursively a list of sets.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          conf = styxlib.utils.merge [
            (styxlib.themes.loadConf { inherit themes; })
            (import ./conf.nix)
            extraConf
          ];
        '';
      })
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.merge [ { a = 1; b = 2; } { b = "x"; c = "y"; } ]
        '';
        code = styxlib.utils.merge [
          {
            a = 1;
            b = 2;
          }
          {
            b = "x";
            c = "y";
          }
        ];
        expected = {
          a = 1;
          b = "x";
          c = "y";
        };
      })
    ];

    function = l.foldl' (
      set: acc:
        l.recursiveUpdate set acc
    ) {};
  };

  /*
  ===============================================================

   sortBy

  ===============================================================
  */

  sortBy = utils.documentedFunction {
    description = "Sort a list of attribute sets by attribute.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.sortBy "priority" "asc" [ { priority = 5; } { priority = 2; } ]
        '';
        code =
          styxlib.utils.sortBy "priority" "asc" [{priority = 5;} {priority = 2;}];
        expected = [{priority = 2;} {priority = 5;}];
      })
    ];

    function = attribute: order:
      l.sort (a: b:
        if order == "asc"
        then a."${attribute}" < b."${attribute}"
        else if order == "dsc"
        then a."${attribute}" > b."${attribute}"
        else abort "Sort order must be 'asc' or 'dsc'");
  };

  /*
  ===============================================================

   dirContains

  ===============================================================
  */

  dirContains = utils.documentedFunction {
    description = "Check if a path exists in a directory.";

    function = dir: path: let
      pathArray = l.filter (x: x != "") (l.splitString "/" path);
      loop = base: path: let
        contents = l.readDir base;
      in
        if l.hasAttrByPath [(l.head path)] contents
        then
          if l.length path > 1
          then loop (base + "/${l.head path}") (l.tail path)
          else true
        else false;
    in
      loop dir pathArray;
  };

  /*
  ===============================================================

   setToList

  ===============================================================
  */

  setToList = utils.documentedFunction {
    description = "Convert a deep set to a list of sets where the key is the path.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.setToList { a.b.c = true; d = "foo"; x.y.z = [ 1 2 3 ]; }
        '';
        code = styxlib.utils.setToList {
          a.b.c = true;
          d = "foo";
          x.y.z = [1 2 3];
        };
        expected = [{"a.b.c" = true;} {d = "foo";} {"x.y.z" = [1 2 3];}];
      })
    ];

    function = s: let
      f = path: set:
        map (
          key: let
            value = set.${key};
            newPath = path ++ [key];
            pathString = l.concatStringsSep "." newPath;
          in
            if l.isAttrs value
            then f newPath value
            else {"${pathString}" = value;}
        ) (l.attrNames set);
    in
      l.flatten (f [] s);
  };

  /*
  ===============================================================

   isPath

  ===============================================================
  */

  isPath = utils.documentedFunction {
    description = "Check if the parameter is a path";

    function = x: (! l.isAttrs x) && l.types.path.check x;
  };

  /*
  ===============================================================

   importApply

  ===============================================================
  */

  importApply = utils.documentedFunction {
    description = "Import a nix file `file` and apply the arguments `arg` if it is a function.";

    arguments = [
      {
        name = "file";
        description = "Nix file to load.";
        type = "Path";
      }
      {
        name = "arg";
        description = "Argument to call `file` contents with if it is a function.";
      }
    ];

    function = file: arg: let
      f = import file;
    in
      if l.isFunction f
      then f arg
      else f;
  };

  /*
  ===============================================================

   mod

  ===============================================================
  */

  mod = utils.documentedFunction {
    description = "Returns the remainder of a division.";

    arguments = [
      {
        name = "dividend";
        description = "Dividend.";
        type = "Int";
      }
      {
        name = "divisor";
        description = "Divisor.";
        type = "Int";
      }
    ];

    return = "Division remainder.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.mod 3 2
        '';
        code =
          styxlib.utils.mod 3 2;
        expected = 1;
      })
    ];

    function = a: b: a - (b * (a / b));
  };

  /*
  ===============================================================

   isOdd

  ===============================================================
  */

  isOdd = utils.documentedFunction {
    description = "Checks if a number is odd.";

    arguments = [
      {
        name = "a";
        description = "Number to check.";
        type = "Int";
      }
    ];

    return = "`Bool`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.isOdd 3
        '';
        code =
          styxlib.utils.isOdd 3;
        expected = true;
      })
    ];

    function = a: (utils.mod a 2) == 1;
  };

  /*
  ===============================================================

   isEven

  ===============================================================
  */

  isEven = utils.documentedFunction {
    description = "Checks if a number is even.";

    arguments = [
      {
        name = "a";
        description = "Number to check.";
        type = "Int";
      }
    ];

    return = "`Bool`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.isEven 3
        '';
        code =
          styxlib.utils.isEven 3;
        expected = false;
      })
    ];

    function = a: (utils.mod a 2) == 0;
  };

  /*
  ===============================================================

   prettyNix

  ===============================================================
  */

  prettyNix = utils.documentedFunction {
    description = "Pretty print nix values.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.utils.prettyNix [ { a.b.c = true; } { x.y.z = [ 1 2 3 ]; } ]
        '';
        code =
          styxlib.utils.prettyNix [{a.b.c = true;} {x.y.z = [1 2 3];}];
        expected = ''
          [ {
            a = {
              b = {
                c = true;
              };
            };
          } {
            x = {
              y = {
                z = [ 1 2 3 ];
              };
            };
          } ]'';
      })
    ];

    function = expr: let
      indent = n: l.concatStrings (l.genList (x: " ") (n * 2));
      isLit = x: l.isAttrs x && x ? _type && x._type == "literalExpression";
      loop = n: x:
        if l.isString x
        then ''"${l.replaceStrings [''"''] [''\"''] x}"''
        else if l.isInt x
        then l.toString x
        else if l.isNull x
        then "null"
        else if l.isList x
        then ''[ ${l.concatStringsSep " " (map (loop n) x)} ]''
        else if l.isBool x
        then l.toJSON x
        else if x == {}
        then ''{ }''
        else if isLit x
        then x.text
        else if l.isDerivation x
        then "(build of ${x.name})"
        else if l.isAttrs x
        then ''
          {
          ${indent (n + 1)}${l.concatStringsSep "\n${indent (n + 1)}" (l.mapAttrsToList (k: v: let
            k' =
              if
                (l.match "^(.+)[.](.+)$" k)
                != null
                || (l.match "^(.+)[ \t\r\n](.+)$" k) != null
              then ''"${k}"''
              else k;
          in "${k'} = ${loop (n + 1) v};")
          x)}
          ${indent n}}''
        else if l.isFunction x
        then ''<function>''
        else if (l.typeOf x == "path")
        then ''`${l.toString x}`''
        else "";
    in
      loop 0 expr;
  };
}
