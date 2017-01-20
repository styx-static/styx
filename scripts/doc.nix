/* Expression to generate the themes configuration interface doc
*/
{ pkgs ? import ../nixpkgs }:

let 

styxLib  = pkgs.callPackage ../src/lib {};

# themes meta information to generate the documentation
themes = with styxLib;
  let
    themesDrv = (filterAttrs (k: v: isDerivation v) pkgs.styx-themes);
    data      = map (t: { exampleSrc = readFile (t + "/example/site.nix"); } // (styxLib.themes.loadData { inherit styxLib; theme = t; })) (attrValues themesDrv);
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

prettyJSON = raw:
  let
    result =pkgs.runCommand "parsed-data" {
      buildInputs = [ pkgs.jq ];
    } "jq -M . <<< '${styxLib.replaceStrings ["'"] ["'\i'''"] (builtins.toJSON raw)}' > $out";
  in styxLib.fileContents result;

styx-doc = with styxLib;

{ stdenv
, writeText
}:

stdenv.mkDerivation rec {
  name    = "styx-docs";
  unpackPhase = ":";

  doc = writeText "doc" ''

    ${mapTemplate (theme: ''
      [[${theme.meta.id}]]
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

      ${optionalString (theme.meta ? documentation) ''
        
        === Documentation

        :leveloffset: +2

        ${theme.meta.documentation}

        :leveloffset: -2

      ''} 

      === Configuration interface

      :sectnums!:

      ---
      ${mapTemplate (prop:
      let
        data = propValue prop;
      in
      ''
        ==== ${propKey prop}

        ${optionalString (data ? description) "Description:: ${data.description}"}
        ${optionalString (data ? type) "Type:: ${data.type}"}
        ${optionalString (data ? default) ''
        Default::
        +
        ----
        ${prettyJSON data.default}
        ----
        ''}
        ${optionalString (data ? example) ''
        Example::
        +
        ----
        ${prettyJSON data.example}
        ----

        ''}

        ---


      '') (docText (mkDoc { inherit (theme) decls; }))}

      :sectnums:

      === Example site source

      [source, nix]
      ----
      ${theme.exampleSrc}
      ----

    '') themes}
  '';

  installPhase = ''
    mkdir $out
    cp $doc $out/styx-themes-generated.adoc
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
