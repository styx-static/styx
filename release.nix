/* File for a Hydra jobset to build styx
*/
{ nixpkgs ? <nixpkgs>
, systems ? ["i686-linux" "x86_64-linux" ]
}:

{
  styx = (import <nixpkgs/lib>).genAttrs systems (system:
    import ./default.nix {
      pkgs = import nixpkgs { inherit system; };
    }
  );
}
