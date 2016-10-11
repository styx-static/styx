# utilities

lib:
with lib;

{

  /* Override the conf attribute set with an attribute set.
     Update is recursive and only keys with a non-null value are updated.
  */
  overrideConf = conf: override:
    conf // (filterAttrs (k: v: (hasAttr k conf) && (v != null)) override);

  /* Set a default layout to a page attribute set
     Does nothing if a layout is already set
  */
  setDefaultLayout = layout: page:
    if page ? layout
       then page
       else page // {  inherit layout; };

  /* Attach a template to a page attribute set
  */
  setTemplate = template: page: page // { inherit template; };

}
