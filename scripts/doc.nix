/* Expression to generate the themes configuration interface doc
*/
{ pkgs ? import <nixpkgs> {} }:

let 

styxLib  = pkgs.callPackage ../src/lib {};

# themes meta information to generate the documentation
themes = with styxLib;
  let
    themesDrv = (filterAttrs (k: v: isDerivation v) pkgs.styx-themes);
    data      = map (t: styxLib.themes.loadData { inherit styxLib; theme = t; }) (attrValues themesDrv);
    # adding some data
    data'     = map (t:
                  let
                    preMeta = { meta.name = t.meta.id; };
                    postMeta = if t.meta ? screenshot 
                               then { meta.screenshotPath = "imgs/${t.meta.id}.png"; }
                               else {};
                  in styxLib.utils.merge [ preMeta t postMeta ]
                ) data;
  in data';

styx-doc = with styxLib;

{ stdenv
, styx-themes
, writeText
, callPackage }:

stdenv.mkDerivation rec {
  name    = "styx-docs";
  unpackPhase = ":";

  doc = writeText "doc" ''

    ${mapTemplate (theme: ''
      == ${theme.meta.name}

      ${optionalString (theme.meta ? description) theme.meta.description}
      ${optionalString (theme.meta ? longDescription) theme.meta.longDescription}

      ---

      ${optionalString (theme.meta ? demoPage) "- ${theme.meta.demoPage}[Demo]"}
      ${optionalString (theme.meta ? homepage) "- ${theme.meta.homepage}[Homepage]"}


      ${optionalString (theme.meta ? screenshotPath) ''
      ---

      image::${theme.meta.screenshotPath}[${theme.meta.name},align="center"]
      ''}

      === Configuration interface

      :sectnums!:

      ---
      ${mapTemplate (data:
      let isSet = x: hasAttr x data && data."${x}" != null;
      in
      ''
        ==== ${data.pathString} 

        ${optionalString (isSet "description") "Description:: ${data.description}"}
        ${optionalString (isSet "type") "Type:: ${data.type}"}
        ${optionalString (isSet "default") ''
        Default::
        +
        ----
        ${toJSON data.default}
        ----
        ''}
        ${optionalString (isSet "example") ''
        Example::
        +
        ----
        ${toJSON data.example}
        ----

        ''}

        ---


      '') (mkDocs { inherit (theme) docs decls; })}

      :sectnums:

    '') themes}
  '';

  installPhase = ''
    mkdir $out
    cp $doc $out/styx-themes.adoc
    ${mapTemplate (t:
      optionalString (t.meta ? screenshotPath) ''
        mkdir -p $(dirname "$out/${t.meta.screenshotPath}")
        cp ${t.meta.screenshot} "$out/${t.meta.screenshotPath}"
      ''
    ) themes}
  '';
}

;in
  pkgs.callPackage styx-doc {}
