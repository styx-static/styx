# TODO: remove this file
import (builtins.fetchTree {
  type = "github";
  owner = "nixos";
  repo = "nixpkgs";
  # keep in line with flake.lock
  narHash = "sha256-uOB0oxqxN9K7XGF1hcnY+PQnlQJ+3bP2vCn/+Ru/bbc=";
  rev = "14ccaaedd95a488dd7ae142757884d8e125b3363";
}) {
  system =
    builtins.currentSystem
    # currently needed for (pure) tests -> only work on that platfrom
    or "x86_64-linux";
}
