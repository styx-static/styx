{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (cell) styxlib docslib;
  inherit (cell.styxlib) utils;

  l = nixpkgs.lib // builtins;
in {
  pagesDoc = pages: ''
    == Pages List
    The site contains ${toString (l.length pages)} generated pages:
    ${styxlib.template.mapTemplate (page: ''
        * `${page.path}`
      '')
      pages}
  '';
  themesDoc = env: themes: ''
    == Used Themes

    :leveloffset: +1
    ${styxlib.template.mapTemplate (theme: ''
        [[${theme.meta.id}]]
        == ${theme.meta.name}
        ${l.optionalString (theme.meta ? description) theme.meta.description}
        ${l.optionalString (theme.meta ? longDescription) theme.meta.longDescription}
        ---
        ${l.optionalString (theme.meta ? demoPage) "- ${theme.meta.demoPage}[Demo]"}
        ${l.optionalString (theme.meta ? homepage) "- ${theme.meta.homepage}[Homepage]"}
        ${l.optionalString (theme.meta ? screenshot) ''
          ---
          image::${docslib.mkScreenshotPath theme}[${theme.meta.name},align="center"]
        ''}
        ${l.optionalString (theme.meta ? documentation) ''
          [[${theme.meta.id}.doc]]
          === Documentation
          :leveloffset: +2
          ${theme.meta.documentation}
          :leveloffset: -2
        ''}
        ${l.optionalString (theme ? decls) ''
          [[${theme.meta.id}.conf]]
          === Configuration interface
          :sectnums!:
          ---
          ${l.concatStringsSep "" (styxlib.proplist.propMap (docslib.mkConfDoc theme.meta.id) (styxlib.themes.docText (styxlib.themes.mkDoc theme.decls)))}
        ''}
        :sectnums:
        ${l.optionalString (theme ? templates) ''
          [[${theme.meta.id}.templates]]
          === Templates
          :sectnums!:
          ---
          ${l.concatStringsSep "" (styxlib.proplist.propMap (docslib.mkTemplateDoc env theme.meta.id) (utils.setToList theme.templates))}
          :sectnums:
        ''}
        ${l.optionalString (theme ? exampleSrc) ''
          [[${theme.meta.id}.example]]
          === Example site source
          [source, nix]
          ----
          ${theme.exampleSrc}
          ----
        ''}
      '')
      themes}

      :leveloffset: -1
  '';

  /*
  auxiliaries
  */
  mkScreenshotPath = t: "imgs/${t.meta.id}.png";
  mkTemplateDoc = env: id: path: template: let
    template' = template (env // {genDoc = true;});
  in ''
    [[${id}.templates.${path}]]
    ==== templates.${path}
    ${l.optionalString (styxlib.template.isDocTemplate template') ''
      ${l.optionalString (template' ? description) "Description:: ${template'.description}"}
      ${l.optionalString (template' ? arguments) (docslib.mkTemplateArgs template'.arguments)}
      ${l.optionalString (template' ? examples) "Example:: ${l.concatStringsSep "+\n---" (map docslib.mkTemplateExample template'.examples)}"}
      ${l.optionalString (template' ? notes) "[NOTE]\n====\n${template'.notes}\n====\n"}
    ''}
    ---
  '';
  mkConfDoc = id: path: conf: ''
    [[${id}.theme.${path}]]
    ==== theme.${path}
    ${l.optionalString (conf ? description) "Description:: ${conf.description}"}
    ${l.optionalString (conf ? type) "Type:: ${conf.type}"}
    ${l.optionalString (conf ? default) ''
      Default::
      +
      [source, nix]
      ----
      ${utils.prettyNix conf.default}
      ----
    ''}
    ${l.optionalString (conf ? example) ''
      Example::
      +
      [source, nix]
      ----
      ${utils.prettyNix conf.example}
      ----
    ''}
    ---
  '';
  mkTemplateArgs = args: let
    args' =
      if l.isAttrs args
      then l.mapAttrsToList (name: data: data // {inherit name;}) args
      else args;
    type =
      if l.isAttrs args
      then " (Attribute Set)"
      else " (Standard)";
  in
    "Arguments${type}::\n"
    + l.concatStringsSep "\n" (map (
        arg: let
          description = l.optionalString (arg ? description) arg.description;
          type = l.optionalString (arg ? type) "Type: `${arg.type}`. ";
          default = l.optionalString (arg ? default) "Optional, defaults to `${utils.prettyNix arg.default}`.";
        in
          "`${arg.name}`::: " + (l.concatStringsSep " +\n" (l.filter (x: x != "") [description type default]))
      )
      args')
    + "\n";
  mkTemplateExample = example: ''
    +
    [source, nix]
    .Code
    ----
    ${example.literalCode}
    ----
    ${l.optionalString (example ? code) (
      if l.isString example.code
      then ''
        +
        [source, html]
        .Result
        ----
        ${example.code}
        ----
      ''
      else ''
        +
        [source, nix]
        .Result
        ----
        ${utils.prettyNix example.code}
        ----
      ''
    )}
  '';

  /*
  function aux
  */
  mkFunctionDoc = function: ''

    :sectnums!:

    [[${function.fullname}]]
    === ${function.name}

    ${l.optionalString (function ? description) "==== Description\n\n${function.description}\n"}
    ${l.optionalString (function ? arguments) (docslib.mkFunctionArgs function.arguments)}
    ${l.optionalString (function ? return) "==== Return\n\n${function.return}\n"}
    ${l.optionalString (function ? examples) "==== Example\n\n${l.concatStringsSep "\n---\n" (map docslib.mkFunctionExample function.examples)}\n"}
    ${l.optionalString (function ? notes) "[NOTE]\n====\n${function.notes}\n====\n"}

    :sectnums:

  '';

  mkFunctionArgs = args: let
    args' =
      if l.isAttrs args
      then l.mapAttrsToList (name: data: data // {inherit name;}) args
      else args;
    type =
      if l.isAttrs args
      then " (Attribute Set)"
      else " (Standard)";
    isMultiline = arg: let
      arg' =
        if utils.is "literalExpression" arg
        then arg.text
        else arg;
    in
      if l.isString arg'
      then (l.match "^.*(\n).*$" arg') != null
      else false;
  in
    "==== Arguments${type}\n\n"
    + l.concatStringsSep "\n" (map (
        arg: let
          description = l.optionalString (arg ? description) arg.description;
          type = l.optionalString (arg ? type) "Type: `${arg.type}`. ";
          default =
            l.optionalString (arg ? default)
            (
              if isMultiline arg.default
              then "Optional, defaults to:\n\n[source, nix]\n----\n${utils.prettyNix arg.default}\n----\n"
              else "Optional, defaults to `${utils.prettyNix arg.default}`."
            );
          example =
            l.optionalString (arg ? example)
            (
              if isMultiline arg.example
              then "Example:\n\n[source, nix]\n----\n${utils.prettyNix arg.example}\n----\n"
              else "Example: `${utils.prettyNix arg.example}`."
            );
        in
          "\n===== ${arg.name}\n\n" + (l.concatStringsSep "\n\n" (l.filter (x: x != "") [description type default example]))
      )
      args')
    + "\n";

  mkFunctionExample = example:
    l.optionalString (example ? literalCode)
    ''

      [source, nix]
      .Code
      ----
      ${example.literalCode}
      ----
      ${
        l.optionalString (example ? code) ''

          [source, nix]
          .Result
          ----
          ${utils.prettyNix (example.displayCode example.code)}
          ----
        ''
      }

    '';
}
