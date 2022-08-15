{
  inputs,
  cell,
}: let
  inherit (inputs) std;
in
  with std.yants "//styx/renderes/types"; {
    site = struct "site" {
      name = option string;
      pages = option (attrs any);
      data = option (attrs any);
      loaded = struct "loaded" {
        docs = any;
        files = any;
        l = any;
        styxlib = any;
        lib = any;
        decls = any;
        env = any;
        conf = any;
        templates = any;
        themes = any;
      };
      site = drv;
      override = any;
      overrideDerivation = any;
    };
  }
