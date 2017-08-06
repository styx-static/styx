{ stdenv }:
let
  theme = "hyde";
  version = "dev";
in stdenv.mkDerivation rec {
  name    = "${theme}-${version}";
  src     =  ./.;
  installPhase = ''mkdir $out && cp -r $src/* $out/'';
}
