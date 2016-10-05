# utilities

lib:
with lib;

{

  /* Override the conf attribute set with an attribute set.
     Update is recursive and only keys with a non-null value are updated.
  */
  overrideConf = conf: override:
    conf // (filterAttrs (k: v: (hasAttr k conf) && (v != null)) override);

  /* Load a template with an environment set
  */
  loadTemplateWithEnv = env: file: import (env.conf.templatesDir + "/${file}") env;

  /* Attach a template to a page attribute set
  */
  setTemplate = template: page: page // { inherit template; };

}
