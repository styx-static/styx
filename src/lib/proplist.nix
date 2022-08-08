/* library to deal with properties (single key attribute set), and property lists

   Property example:

     { foo = "bar"; }

   Property list example:

     [ { foo = "bar"; } { baz = "buz"; } ]
*/

{lib, ...}@args:
with lib;
with (import ./utils.nix args);

rec {

  _documentation = _: ''
    The proplist namespace contains functions to manipulate property lists, list of attribute set with only one attribute.

    Property lists are used in the taxonomy data structure.

    Example:

    [source, nix]
    ----
    [ { type = "fruit"; } { name = "Apple"; } ]
    ----
  '';

/*
===============================================================

 propKey

===============================================================
*/

  propKey = documentedFunction {
    description = "Get the key of a property.";

    arguments = [
      {
        name = "prop";
        description = "The property to extract the key from.";
        type = "Property";
      }
    ];

    return = "Key of the property.";

    examples = [ (mkExample {
      literalCode = ''
        propKey { name = "Alice"; }
      '';
      code =
        propKey { name = "Alice"; }
      ;
      expected = "name";
    }) ];

    function = prop: head (attrNames prop);
  };


/*
===============================================================

 propValue

===============================================================
*/

  propValue = documentedFunction {
    description = "Get the value of a property.";

    arguments = [
      {
        name = "prop";
        description = "The property to extract the value from.";
        type = "Property";
      }
    ];

    return = "The value of the property.";

    examples = [ (mkExample {
      literalCode = ''
        propValue { name = "Alice"; }
      '';
      code =
        propValue { name = "Alice"; }
      ;
      expected = "Alice";
    }) ];

    function = prop: head (attrValues prop);
  };


/*
===============================================================

 isDefined

===============================================================
*/

  isDefined = documentedFunction {
    description = "Check if a property with a key exists in a property list.";

    arguments = [
      {
        name = "key";
        description = "Key of the property to check existence.";
        type = "String";
      }
      {
        name = "proplist";
        description = "The property list to check.";
        type = "PropList";
      }
    ];

    return = "`Bool`";

    examples = [ (mkExample {
      literalCode = ''
        isDefined "name" [ { name = "Alice"; } ]
      '';
      code =
        isDefined "name" [ { name = "Alice"; } ]
      ;
      expected = true;
    }) ];

    function = key: list:
        let keys = map propKey list;
      in if (length list) > 0
            then elem key keys
            else false;
  };


/*
===============================================================

 getValue

===============================================================
*/

  getValue = documentedFunction {
    description = "Get a value from a property in a property list by the key name.";

    arguments = [
      {
        name = "key";
        description = "Key of the property to extract value.";
        type = "String";
      }
      {
        name = "proplist";
        description = "The property list to extract the value from.";
        type = "PropList";
      }
    ];

    return = "The value of the property.";

    examples = [ (mkExample {
      literalCode = ''
        getValue "name" [ { name = "Alice"; } ]
      '';
      code =
        getValue "name" [ { name = "Alice"; } ]
      ;
      expected = "Alice";
    }) ];

    function = key: list: head (catAttrs key list);
  };


/*
===============================================================

 getProp

===============================================================
*/

  getProp = documentedFunction {
    description = "Get a property in a property list by the key name.";

    arguments = [
      {
        name = "key";
        description = "Key of the property to extract.";
        type = "String";
      }
      {
        name = "proplist";
        description = "The property list to extract the property from.";
        type = "PropList";
      }
    ];

    return = "`Property`";

    examples = [ (mkExample {
      literalCode = ''
        getProp "name" [ { name = "Alice"; } ]
      '';
      code =
        getProp "name" [ { name = "Alice"; } ]
      ;
      expected = { name = "Alice"; };
    }) ];

    function = key: list: head (filter (x: (propKey x) == key) list);
  };


/*
===============================================================

 removeProp

===============================================================
*/

  removeProp = documentedFunction {
    description = "Return a property list where the property with key `key` has been removed.";

    arguments = [
      {
        name = "key";
        description = "Key of the property to remove.";
        type = "String";
      }
      {
        name = "proplist";
        description = "The property list to remove the property from.";
        type = "PropList";
      }
    ];

    return = "`PropList`";

    examples = [ (mkExample {
      literalCode = ''
        removeProp "name" [ { name = "Alice"; } { hobby = "Sports"; } ]
      '';
      code =
        removeProp "name" [ { name = "Alice"; } { hobby = "Sports"; } ]
      ;
      expected = [ { hobby = "Sports"; } ];
    }) ];

    function = key: list: filter (p: (propKey p) != key) list;
  };


/*
===============================================================

 propMap

===============================================================
*/

  propMap = documentedFunction {
    description = "Map for property lists.";

    arguments = [
      {
        name = "f";
        description = "Function to map to the property list.";
        type = "PropKey -> PropValue -> a";
      }
      {
        name = "proplist";
        description = "The property list to map.";
        type = "PropList";
      }
    ];

    return = "`[ a ]`";

    examples = [ (mkExample {
      literalCode = ''
        propMap (k: v: "''${k}: ''${v}") [ { name = "Alice"; } { hobby = "Sports"; } ]
      '';
      code =
        propMap (k: v: "${k}: ${v}") [ { name = "Alice"; } { hobby = "Sports"; } ]
      ;
      expected = [ "name: Alice" "hobby: Sports" ];
    }) ];

    function = f: list: map (p: f (propKey p) (propValue p)) list;
  };


/*
===============================================================

 propFlatten

===============================================================
*/

  propFlatten = documentedFunction {
    description = "Flatten a property list which values are lists.";

    arguments = [
      {
        name = "proplist";
        description = "The property list to flatten.";
        type = "PropList";
      }
    ];

    return = "The flattened property list.";

    examples = [ (mkExample {
      literalCode = ''
        propFlatten [ { foo = [ 1 2 ]; } { bar = "baz"; } { foo = [ 3 4 ]; } ]
      '';
      code =
        propFlatten [ { foo = [ 1 2 ]; } { bar = "baz"; } { foo = [ 3 4 ]; } ]
      ;
      expected = [
        { foo = [ 1 2 3 4 ]; }
        { bar = "baz"; }
      ];
    }) ];

    function = plist:
      fold (p: acc:
        let k = propKey p;
        in if isDefined k acc && isList (propValue p) && isList (getValue k acc)
           then [ { "${k}" = (propValue p) ++ (getValue k acc); } ] ++ (removeProp k acc)
           else [ p ] ++ acc
      ) [] plist;
  };

}
