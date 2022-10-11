{
  inputs,
  cell,
  site,
}: let
  inherit (inputs) nixpkgs;
  inherit (cell) docslib;

  styxlib = (import (inputs.self + /src/lib)) {
    pkgs = nixpkgs;
    conf = site.loaded.conf;
  };

  l = nixpkgs.lib // builtins;

  namespaces = let
    fqFunctionName = namespace: name: "lib.${namespace}.${name}";
  in
    l.mapAttrs (
      namespace: _: let
        libset = site.loaded.lib.${namespace};
        docFunctons = l.filterAttrs (_: styxlib.utils.isDocFunction) libset;
        functions = l.mapAttrsToList (name: fn:
          fn
          // {
            inherit namespace name;
            fullname = fqFunctionName namespace name;
          })
        docFunctons;
      in {
        inherit functions;
        documentation = l.optionalString (libset ? _documentation) (libset._documentation true);
      }
    )
    {
      "conf" = null;
      "data" = null;
      "generation" = null;
      "pages" = null;
      "proplist" = null;
      "template" = null;
      "themes" = null;
      "utils" = null;
    };

  doc = nixpkgs.writeText "lib.adoc" ''

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
