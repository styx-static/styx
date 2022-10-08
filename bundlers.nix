/*
Bundlers implement the CLI's functions on a traget flake.

- They know how to render a site, with or without drafts.

- They also know how to render the documentation of a site.
*/
{
  themes,
  pkgs,
  lib,
}: let
  callStyxSite = site: let
   call = lib.flip (lib.callPackageWith (pkgs // {inherit themes lib;}) {});
   res = call site;
  in res.site or res;
in rec {
  render = callStyxSite;
  renderWithDrafts = site: (callStyxSite site) {
    withDrafts = true;
  };
  document = site': with lib;
    let
      inherit ((callStyxSite site') {
        siteUrl = "http://domain.org";
        siteDocumentation = true;
      }) styx;

      site = {
        inherit (styx.themes) conf lib files templates;
        inherit (styx.themes.env) data pages;
      };

      mkScreenshotPath = t: "imgs/${t.meta.id}.png";

      themesData = styx.themes;

      themes = reverseList themesData.themes;

      pages =
        if site ? pages
        then
          if isAttrs site.pages
          then pagesToList {inherit (site) pages;}
          else site.pages
        else [];

      mkTemplateExample = example: ''

        +
        [source, nix]
        .Code
        ----
        ${example.literalCode}
        ----

        ${optionalString (example ? code) (
          if isString example.code
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
            ${prettyNix example.code}
            ----
          ''
        )}

      '';

      mkTemplateArgs = args: let
        args' =
          if isAttrs args
          then mapAttrsToList (name: data: data // {inherit name;}) args
          else args;
        type =
          if isAttrs args
          then " (Attribute Set)"
          else " (Standard)";
      in
        "Arguments${type}::\n"
        + concatStringsSep "\n" (map (
            arg: let
              description = optionalString (arg ? description) arg.description;
              type = optionalString (arg ? type) "Type: `${arg.type}`. ";
              default = optionalString (arg ? default) "Optional, defaults to `${prettyNix arg.default}`.";
            in
              "`${arg.name}`::: " + (concatStringsSep " +\n" (filter (x: x != "") [description type default]))
          )
          args')
        + "\n";

      mkTemplateDoc = id: path: template: let
        env' =
          if site ? env
          then site.env
          else {inherit (site) conf templates lib data pages;};
        template' = template (env' // {genDoc = true;});
      in ''

        [[${id}.templates.${path}]]
        ==== templates.${path}

        ${optionalString (isDocTemplate template') ''
          ${optionalString (template' ? description) "Description:: ${template'.description}"}
          ${optionalString (template' ? arguments) (mkTemplateArgs template'.arguments)}
          ${optionalString (template' ? examples) "Example:: ${concatStringsSep "+\n---" (map mkTemplateExample template'.examples)}"}
          ${optionalString (template' ? notes) "[NOTE]\n====\n${template'.notes}\n====\n"}
        ''}

        ---

      '';

      mkConfDoc = id: path: conf: ''
        [[${id}.theme.${path}]]
        ==== theme.${path}

        ${optionalString (conf ? description) "Description:: ${conf.description}"}
        ${optionalString (conf ? type) "Type:: ${conf.type}"}
        ${optionalString (conf ? default) ''
          Default::
          +
          [source, nix]
          ----
          ${prettyNix conf.default}
          ----
        ''}
        ${optionalString (conf ? example) ''
          Example::
          +
          [source, nix]
          ----
          ${prettyNix conf.example}
          ----

        ''}

        ---

      '';

      pagesDoc = optionalString (pages != []) ''

        == Pages List

        The site contains ${toString (length pages)} generated pages:

        ${mapTemplate (page: ''
            * `${page.path}`
          '')
          pages}

      '';

      themesDoc = optionalString (themes != []) ''

        ${mapTemplate (theme: ''
            [[${theme.meta.id}]]
            == ${theme.meta.name}

            ${optionalString (theme.meta ? description) theme.meta.description}
            ${optionalString (theme.meta ? longDescription) theme.meta.longDescription}

            ---

            ${optionalString (theme.meta ? demoPage) "- ${theme.meta.demoPage}[Demo]"}
            ${optionalString (theme.meta ? homepage) "- ${theme.meta.homepage}[Homepage]"}


            ${optionalString (theme.meta ? screenshot) ''
              ---

              image::${mkScreenshotPath theme}[${theme.meta.name},align="center"]

            ''}

            ${optionalString (theme.meta ? documentation) ''

              [[${theme.meta.id}.doc]]
              === Documentation

              :leveloffset: +2

              ${theme.meta.documentation}

              :leveloffset: -2

            ''}

            ${optionalString (theme ? decls) ''

              [[${theme.meta.id}.conf]]
              === Configuration interface

              :sectnums!:

              ---

              ${concatStringsSep "" (propMap (mkConfDoc theme.meta.id) (docText (mkDoc theme.decls)))}

            ''}

            :sectnums:

            ${optionalString (theme ? templates) ''

              [[${theme.meta.id}.templates]]
              === Templates

              :sectnums!:

              ---

              ${concatStringsSep "" (propMap (mkTemplateDoc theme.meta.id) (setToList theme.templates))}

              :sectnums:

            ''}

            ${optionalString (theme ? exampleSrc) ''

              [[${theme.meta.id}.example]]
              === Example site source

              [source, nix]
              ----
              ${theme.exampleSrc}
              ----

            ''}

          '')
          themes}

      '';
    in
      pkgs.stdenv.mkDerivation rec {
        name = "styx-docs";
        unpackPhase = ":";

        preferLocalBuild = true;
        allowSubstitutes = false;

        buildInputs = [pkgs.asciidoctor];

        doc = pkgs.writeText "site.adoc" ''

          ////

          File automatically generated, do not edit

          ////

          = ${site.name or "Styx Site"} Documentation
          :description: Site documentation
          :toc: left
          :toclevels: 3
          :icons: font
          :sectanchors:
          :nofooter:
          :experimental:
          :source-highlighter: highlightjs
          :highlightjsdir: highlight

          :sectnums:

          ${pagesDoc}

          ${optionalString (themes != []) ''
            == Used Themes

            :leveloffset: +1

            ${themesDoc}

            :leveloffset: -1

          ''}

        '';

        buildPhase = ''
          mkdir build
          asciidoctor $doc -o build/index.html
        '';

        installPhase = ''
          mkdir $out
          ${mapTemplate (
              t:
                optionalString (t.meta ? screenshot) ''
                  mkdir -p $(dirname "$out/${mkScreenshotPath t}")
                  cp ${t.meta.screenshot} "$out/${mkScreenshotPath t}"
                ''
            )
            themes}
          cp build/index.html $out/
          cp -r ${pkgs.styx}/share/doc/styx/highlight $out/
          cp ${pkgs.writeText "themes.adoc" themesDoc} $out/themes-generated.adoc
        '';
      };
}
