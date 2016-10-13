/* library to deal with properties (single key attribute set), and property lists

   Property example:

     { foo = "bar"; }

   Property list example:

     [ { foo = "bar"; } { baz = "buz"; } ]
*/

lib:
with lib;

rec {

  /* get a value from a property in a property list by the key name
  */
  getValue = key: list: head (catAttrs key list);

  /* get a property from a property list by the key name
  */
  getProp = key: list: head (filter (x: (propKey x) == key) list);

  getProps = key: list: filter (x: (propKey x) == key) list;

  /* return a property list where the property with key 'key' has been removed
  */
  removeProp = key: list: filter (p: (propKey p) != key) list;

  /* Check if a property with a key exists in a property list
  */
  isDefined = key: list:
    let keys = map (p: (head (attrNames p))) list;
  in if (length list) > 0
        then elem key keys
        else false;

  /* get key from a property
  */
  propKey = prop: head (attrNames prop);

  /* get value from a property
  */
  propValue = prop: head (attrValues prop);

  /* flatten a property list that which values are lists
  */
  flatten = plist:
    fold (p: acc:
      let k = propKey p;
      in if isDefined k acc
         then [ { "${k}" = (propValue p) ++ (getValue k acc); } ] ++ (removeProp k acc)
         else [ p ] ++ acc
    ) [] plist;

}
