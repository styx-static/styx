let 
  pkgs = import ../nixpkgs;
  lib = pkgs.callPackage pkgs.styx.lib {};
in

with pkgs;
with lib;

let

  libs = map (namespace: 
    let functions = filter (x: x != {}) (mapAttrsToList (name: fn:
      let docFn = fn { _type = "genDoc"; };
      in optionalAttrs (isDocFunction docFn)
           { fullname = "lib.${namespace}.${name}"; inherit docFn namespace name; }
    ) lib."${namespace}");
    in {
      "${namespace}" = {
        inherit functions;
        documentation = optionalString (lib."${namespace}" ? _documentation) (lib."${namespace}"._documentation true);
      };
    });

  namespaces = fold (x: acc:
    acc // x
  ) {} (libs [
    "conf"
    "data"
    "generation"
    "pages"
    "proplist"
    "template"
    "themes"
    "utils"
  ]);

  mkFunctionDoc = fn:
    let
      function = fn.docFn;
    in
    ''

    :sectnums!:

    [[${fn.fullname}]]
    === ${fn.name} 
    
    ${optionalString (function ? description) "==== Description\n\n${function.description}\n"}
    ${optionalString (function ? arguments)   (mkFunctionArgs function.arguments)}
    ${optionalString (function ? return)      "==== Return\n\n${function.return}\n"}
    ${optionalString (function ? examples)    "==== Example\n\n${concatStringsSep "\n---\n" (map mkFunctionExample function.examples)}\n"}
    ${optionalString (function ? notes)       "[NOTE]\n====\n${function.notes}\n====\n"}

    :sectnums:
    
    '';

  mkFunctionArgs = args:
    let
      args' = if isAttrs args
              then mapAttrsToList (name: data: data // { inherit name; }) args
              else args;
      type = if isAttrs args
             then " (Attribute Set)"
             else " (Standard)";
    in "==== Arguments${type}\n\n" + concatStringsSep "\n" (map (arg: 
    let 
      description = optionalString (arg ? description) arg.description;
      type        = optionalString (arg ? type)        "Type: `${arg.type}`. ";
      default     = optionalString (arg ? default)     "Optional, defaults to `${prettyNix arg.default}`.";
    in "\n===== ${arg.name}\n\n" + (concatStringsSep "\n" (filter (x: x != "") [ description type default ]))
    ) args') + "\n";
      /*
      ${if isString example.code
        then example.code
        else prettyNix example.code}
        */

  mkFunctionExample = example:
    ''

      [source, nix]
      .Code
      ----
      ${example.literalCode}
      ----
      ${optionalString (example ? code) ''

      [source, html]
      .Result
      ----
      ${prettyNix example.code}
      ----
      ''
      }

    '';

in stdenv.mkDerivation {

  name    = "styx-docs";

  unpackPhase = ":";

  buildInputs = [ asciidoctor ];

  doc = writeText "lib.adoc" ''

    ////

    File automatically generated, do not edit

    ////

    ${concatStringsSep "\n" (mapAttrsToList (namespace: data: ''

    === ${namespace}

    ${data.documentation}


    :leveloffset: +1

    ---

    ${concatStringsSep "\n\n---\n\n" (map mkFunctionDoc data.functions)}

    ---

    :leveloffset: -1
    
    '') namespaces)}

  '';

  buildPhase = ''
    mkdir build
    cp $doc build/library-generated.adoc 
  '';

  installPhase = ''
    mkdir $out
    cp build/* $out
  '';

}
