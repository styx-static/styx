{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (inputs.nixpkgs) stdenv;

  l = nixpkgs.lib // builtins;
in {
  styx = stdenv.mkDerivation {
    preferLocalBuild = true;
    allowSubstitutes = false;

    pname = "styx";
    version = l.unsafeDiscardStringContext (l.fileContents (inputs.self + /VERSION));

    src = ./cli;

    buildInputs = [nixpkgs.caddy nixpkgs.linkchecker];
    nativeBuildInputs = [nixpkgs.asciidoctor];

    installPhase = ''
      mkdir $out
      install -D -m 777 $src/styx.sh $out/bin/styx
      substituteAllInPlace $out/bin/styx
    '';

    meta = {
      description = "Nix based static site generator";
      maintainers = with l.maintainers; [ericsagnes siraben blaggacao];
      platforms = l.platforms.all;
    };
  };
}
