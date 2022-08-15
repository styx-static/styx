{
  inputs,
  cell,
  site,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.cell) styxlib;
  inherit (inputs.cell.styxlib) utils;

  l = nixpkgs.lib // builtins;

  namespaces = let
    fqFunctionName = namespace: name "lib.${namespace}.${name}";
  in
    l.mapAttrs (
      namespace: libset: let
        functions = l.mapAttrsToList (name: fn:
          fn
          // {
            inherit namespace name;
            fullname = fqFunctionName namespace name;
          })
        (l.filterAttrs (_: utils.isDocFunction) libset);
      in {
        inherit functions;
        documentation = l.optionalString (libset ? _documentation) (libset._documentation true);
      }
    )
    site.loaded.styxlib;

  doc = nixkgs.writeText "lib.adoc" ''

    ////

    File automatically generated, do not edit

    ////

    ${l.concatStringsSep "\n" (
      l.mapAttrsToList (namespace: data: ''

        == ${namespace}

        ${data.documentation}


        ---

        ${l.concatStringsSep "\n\n---\n\n" (map docslib.mkFunctionDoc data.functions)}

        ---


      '')
      namespaces
    )}

  '';
in
  nixpkgs.stdenv.mkDerivation {
    name = "styx-docs";

    preferLocalBuild = true;
    allowSubstitutes = false;

    unpackPhase = ":";

    buildInputs = [nixpkgs.asciidoctor];

    buildPhase = ''
      mkdir build
      cp ${doc} build/library-generated.adoc
    '';

    installPhase = ''
      mkdir $out
      cp build/* $out
    '';
  }
