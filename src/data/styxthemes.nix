# TODO: remove when ./styxtheme/default.nix satifies the std calling contract
# currently this file shadows it
{
  inputs,
  cell,
}:
import ./styxthemes/default.nix {inherit inputs cell;}
