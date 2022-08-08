{ pkgs, lib}: with lib;

let

  namespaces = mapAttrs (namespace: _:
    let functions = filter (x: x != {}) (mapAttrsToList (name: fn:
      optionalAttrs (isDocFunction fn)
        ({ fullname = "lib.${namespace}.${name}"; inherit namespace name; } // fn)
    ) lib."${namespace}");
    in {
      inherit functions;
      documentation = optionalString (lib."${namespace}" ? _documentation) (lib."${namespace}"._documentation true);
    }) {
      conf = {};
      data = {};
      generation = {};
      pages = {};
      proplist = {};
      template = {};
      themes = {};
      utils = {};
    };

  mkFunctionDoc = function:
    ''

    :sectnums!:

    [[${function.fullname}]]
    === ${function.name}

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
      isMultiline = arg:
        let arg' = if is "literalExpression" arg
                   then arg.text
                   else arg;
        in if isString arg'
           then (match "^.*(\n).*$" arg') != null
           else false;
    in "==== Arguments${type}\n\n" + concatStringsSep "\n" (map (arg:
    let
      description = optionalString (arg ? description) arg.description;
      type        = optionalString (arg ? type)        "Type: `${arg.type}`. ";
      default     = optionalString (arg ? default)
                    (if isMultiline arg.default
                     then "Optional, defaults to:\n\n[source, nix]\n----\n${prettyNix arg.default}\n----\n"
                     else "Optional, defaults to `${prettyNix arg.default}`.");
      example     = optionalString (arg ? example)
                    (if isMultiline arg.example
                     then "Example:\n\n[source, nix]\n----\n${prettyNix arg.example}\n----\n"
                     else "Example: `${prettyNix arg.example}`.");
    in "\n===== ${arg.name}\n\n" + (concatStringsSep "\n\n" (filter (x: x != "") [ description type default example ]))
    ) args') + "\n";

  mkFunctionExample = example:
    optionalString (example ? literalCode)
    ''

      [source, nix]
      .Code
      ----
      ${example.literalCode}
      ----
      ${optionalString (example ? code) ''

      [source, nix]
      .Result
      ----
      ${prettyNix (example.displayCode example.code)}
      ----
      ''
      }

    '';

  content =  concatStringsSep "\n" (mapAttrsToList (namespace: data: ''

    == ${namespace}

    ${data.documentation}


    ---

    ${concatStringsSep "\n\n---\n\n" (map mkFunctionDoc data.functions)}

    ---


  '') namespaces);

  doc = pkgs.writeText "lib.adoc" ''

    ////

    File automatically generated, do not edit

    ////

    ${content}

  '';

in pkgs.stdenv.mkDerivation {
  name    = "styx-docs";

  preferLocalBuild = true;
  allowSubstitutes = false;

  unpackPhase = ":";

  buildInputs = [ pkgs.asciidoctor ];

  buildPhase = ''
    mkdir build
    cp ${doc} build/library-generated.adoc
  '';

  installPhase = ''
    mkdir $out
    cp build/* $out
  '';
}
