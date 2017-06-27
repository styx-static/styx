{ stdenv }:

stdenv.mkDerivation rec {
  name    = "generic-templates-${version}";
  version = "dev";
  src     =  ./.;
  installPhase = ''mkdir $out && cp -r $src/* $out/'';
}
