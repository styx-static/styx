    # utils.lib.eachDefaultSystem (system:
    utils.lib.eachSystem [
      "x86_64-linux" "i686-linux""aarch64-linux"
      # "x86_64-darwin" "aarch64-darwin"
    ](system:
      let

        main-tests = import ./tests/main.nix { inherit pkgs lib; };
        lib-tests = import ./tests/lib.nix { inherit pkgs lib; };

        report = pkgs.writeScriptBin "testresult" "${lib.getExe pkgs.bat} ${lib-tests.report} ${lib-tests.coverage}";
        showcase = pkgs.writeScriptBin "showcase-site" "xdg-open ${main-tests.showcase-site}/index.html";
      in
      {
        packages = { inherit styx report showcase update-doc; default = styx;};
      }
    );
  )
