# Page and site generation functions

lib:
with lib;

rec {

  /* get value from a proplist key
  */
  getValue = key: list: head (catAttrs key list);

  /* check if a key is defined
  */
  isDefined = key: list:
    let keys = map (p: (head (attrNames p))) list;
  in elem key keys;

  /* get key from a property
  */
  propKey = prop: head (attrNames prop);

  /* get value from a property
  */
  propValue = prop: head (attrValues prop);

  /* merge a property in property list
  */
  merge = proplist: prop:
    let
      key = propKey prop;
    in
    if isDefined key proplist
       then let
              newProp = { "${key}" = (getValue key proplist) ++ prop."${key}"; };
              oldProps = (filter (i: builtins.attrNames i != [ key ]) proplist);
            in oldProps ++ [ newProp ]
       else proplist ++ [ prop ];

}
