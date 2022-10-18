{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) stdenv;

  l = nixpkgs.lib // builtins;

  styx = stdenv.mkDerivation rec {
    preferLocalBuild = true;
    allowSubstitutes = false;

    inherit (nixpkgs) runtimeShell; # substitued variable

    pname = "styx";
    version = l.unsafeDiscardStringContext (l.fileContents (inputs.self + /VERSION)); # substitued variable

    bin = nixpkgs.writeShellApplication {
      name = pname;
      runtimeInputs = [nixpkgs.caddy nixpkgs.linkchecker nixpkgs.jq nixpkgs.nix];
      text = l.fileContents ./cli/styx.sh;
    };

    nativeBuildInputs = [nixpkgs.asciidoctor];

    phases = ["installPhase" "installCheckPhase"];

    installPhase = ''
      mkdir $out
      install -D -m 777 ${bin}/bin/styx       $out/bin/styx
      substituteInPlace                       $out/bin/styx                        --subst-var version

      # Compatibility
      cp -r ${inputs.self}/* $out

      # Documentation
      mkdir -p                                $out/share/doc/styx
      asciidoctor \
      ${inputs.self}/docs/index.adoc       -o $out/share/doc/styx/index.html
      substituteInPlace                       $out/share/doc/styx/index.html       --subst-var version
      asciidoctor \
      ${inputs.self}/docs/styx-themes.adoc -o $out/share/doc/styx/styx-themes.html
      substituteInPlace                       $out/share/doc/styx/styx-themes.html --subst-var version
      asciidoctor \
      ${inputs.self}/docs/library.adoc     -o $out/share/doc/styx/library.html
      substituteInPlace                       $out/share/doc/styx/library.html     --subst-var version
      cp -r ${inputs.self}/docs/highlight     $out/share/doc/styx/
      cp -r ${inputs.self}/docs/imgs          $out/share/doc/styx/
    '';

    # installCheckPhase = ''
    #   runHook preInstallCheck
    #   $out/bin/styx --version
    #   $out/bin/styx new site my-site
    #   $out/bin/styx gen-sample-data ./my-site
    #   $out/bin/styx new theme my-theme ./my-site/themes
    #   runHook postInstallCheck
    # '';

    meta = {
      description = "Nix based static site generator";
      maintainers = with l.maintainers; [ericsagnes siraben blaggacao];
      platforms = l.platforms.all;
      mainProgram = pname;
    };

    # compat with evtl old themes that use the old calling convention
    passthru = {
      # import pkgs.styx.themes
      themes = "${l.toString inputs.self}/themes-compat.nix";
    };
  };
in {
  inherit styx;
  default = styx;
}
