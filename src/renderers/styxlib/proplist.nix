{
  l,
  styxlib,
}: let
  inherit (styxlib) utils;
  /*
  library to deal with properties (single key attribute set), and property lists

  Property example:

    { foo = "bar"; }

  Property list example:

    [ { foo = "bar"; } { baz = "buz"; } ]
  */
in {
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

  propKey = utils.documentedFunction {
    description = "Get the key of a property.";

    arguments = [
      {
        name = "prop";
        description = "The property to extract the key from.";
        type = "Property";
      }
    ];

    return = "Key of the property.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.propKey { name = "Alice"; }
        '';
        code =
          styxlib.proplist.propKey {name = "Alice";};
        expected = "name";
      })
    ];

    function = prop: l.head (l.attrNames prop);
  };

  /*
  ===============================================================

   propValue

  ===============================================================
  */

  propValue = utils.documentedFunction {
    description = "Get the value of a property.";

    arguments = [
      {
        name = "prop";
        description = "The property to extract the value from.";
        type = "Property";
      }
    ];

    return = "The value of the property.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.propValue { name = "Alice"; }
        '';
        code =
          styxlib.proplist.propValue {name = "Alice";};
        expected = "Alice";
      })
    ];

    function = prop: l.head (l.attrValues prop);
  };

  /*
  ===============================================================

   isDefined

  ===============================================================
  */

  isDefined = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.isDefined "name" [ { name = "Alice"; } ]
        '';
        code =
          styxlib.proplist.isDefined "name" [{name = "Alice";}];
        expected = true;
      })
    ];

    function = key: list: let
      keys = map styxlib.proplist.propKey list;
    in
      if (l.length list) > 0
      then l.elem key keys
      else false;
  };

  /*
  ===============================================================

   getValue

  ===============================================================
  */

  getValue = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.getValue "name" [ { name = "Alice"; } ]
        '';
        code =
          styxlib.proplist.getValue "name" [{name = "Alice";}];
        expected = "Alice";
      })
    ];

    function = key: list: l.head (l.catAttrs key list);
  };

  /*
  ===============================================================

   getProp

  ===============================================================
  */

  getProp = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.getProp "name" [ { name = "Alice"; } ]
        '';
        code =
          styxlib.proplist.getProp "name" [{name = "Alice";}];
        expected = {name = "Alice";};
      })
    ];

    function = key: list: l.head (l.filter (x: (styxlib.proplist.propKey x) == key) list);
  };

  /*
  ===============================================================

   removeProp

  ===============================================================
  */

  removeProp = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.removeProp "name" [ { name = "Alice"; } { hobby = "Sports"; } ]
        '';
        code =
          styxlib.proplist.removeProp "name" [{name = "Alice";} {hobby = "Sports";}];
        expected = [{hobby = "Sports";}];
      })
    ];

    function = key: list: l.filter (p: (styxlib.proplist.propKey p) != key) list;
  };

  /*
  ===============================================================

   propMap

  ===============================================================
  */

  propMap = utils.documentedFunction {
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

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.propMap (k: v: "''${k}: ''${v}") [ { name = "Alice"; } { hobby = "Sports"; } ]
        '';
        code =
          styxlib.proplist.propMap (k: v: "${k}: ${v}") [{name = "Alice";} {hobby = "Sports";}];
        expected = ["name: Alice" "hobby: Sports"];
      })
    ];

    function = f: list: map (p: f (styxlib.proplist.propKey p) (styxlib.proplist.propValue p)) list;
  };

  /*
  ===============================================================

   propFlatten

  ===============================================================
  */

  propFlatten = utils.documentedFunction {
    description = "Flatten a property list which values are lists.";

    arguments = [
      {
        name = "proplist";
        description = "The property list to flatten.";
        type = "PropList";
      }
    ];

    return = "The flattened property list.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.proplist.propFlatten [ { foo = [ 1 2 ]; } { bar = "baz"; } { foo = [ 3 4 ]; } ]
        '';
        code =
          styxlib.proplist.propFlatten [{foo = [1 2];} {bar = "baz";} {foo = [3 4];}];
        expected = [
          {foo = [1 2 3 4];}
          {bar = "baz";}
        ];
      })
    ];

    function = plist:
      l.fold (
        p: acc: let
          k = styxlib.proplist.propKey p;
        in
          if styxlib.proplist.isDefined k acc && l.isList (styxlib.proplist.propValue p) && l.isList (styxlib.proplist.getValue k acc)
          then [{"${k}" = (styxlib.proplist.propValue p) ++ (styxlib.proplist.getValue k acc);}] ++ (styxlib.proplist.removeProp k acc)
          else [p] ++ acc
      ) []
      plist;
  };
}
