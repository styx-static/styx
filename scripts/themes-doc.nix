{ pkgs, lib}: with lib;

pkgs.callPackage ../src/nix/site-doc.nix {
  site = rec {
    styx = import pkgs.styx {
      inherit pkgs;
      config = [{ siteUrl = "http://domain.org"; }];
      themes = reverseList (attrValues (removeAttrs pkgs.styx.themes ["outPath"]));
      env = { data = {}; pages = {}; };
    };
    # Propagating initialized data
    inherit (styx.themes) conf files templates env lib;
  };
}
