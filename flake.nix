{
  description = "The purely functional static site generator in Nix expression language.";

  inputs.utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, utils, nixpkgs, ... }: 
    # utils.lib.eachDefaultSystem (system:
    utils.lib.eachSystem [
      "x86_64-linux" "i686-linux""aarch64-linux"
      # "x86_64-darwin" "aarch64-darwin"
    ](system:
      let
        pkgs = (import nixpkgs { inherit system; }).extend (_: _: { inherit styx; });
        styx = pkgs.callPackage ./derivation.nix { };
        inherit (import ./src/default.nix { inherit pkgs; }) lib;

        main-tests = import ./tests/main.nix { inherit pkgs lib; };
        lib-tests = import ./tests/lib.nix { inherit pkgs lib; };

        report = pkgs.writeScriptBin "testresult" "${lib.getExe pkgs.bat} ${lib-tests.report} ${lib-tests.coverage}";
        showcase = pkgs.writeScriptBin "showcase-site" "xdg-open ${main-tests.showcase-site}/index.html";
        update-doc = let
          library-doc = import ./scripts/library-doc.nix { inherit pkgs lib; };
          themes-doc = import ./scripts/themes-doc.nix { inherit pkgs lib; };
        in pkgs.writeScriptBin "update-doc" ''
          repoRoot="$(git rev-parse --show-toplevel)"
          target="$(readlink -f -- "$repoRoot/src/doc/")"

          if ! cmp "${themes-doc}/themes-generated.adoc" "$target/styx-themes-generated.adoc"
          then
            cp ${themes-doc}/themes-generated.adoc $target/styx-themes-generated.adoc --no-preserve=all
            cp ${themes-doc}/imgs/* $target/imgs/ --no-preserve=all
            echo "Themes documentation updated!"
          fi

          if ! cmp "${library-doc}/library-generated.adoc" "$target/library-generated.adoc"
          then
            cp ${library-doc}/library-generated.adoc $target/library-generated.adoc --no-preserve=all
            echo "Library documentation updated!"
          fi
        '';

        update-themes = pkgs.writeScriptBin "update-themes" ''
          repoRoot="$(git rev-parse --show-toplevel)"
          target="$(readlink -f -- "$repoRoot/themes/versions.nix")"
          source="$(readlink -f -- "$repoRoot/themes/revs.csv")"
          touch "$target"
          echo "{" > "$target"
          while IFS=, read owner theme rev
          do
            hash="$(${lib.getExe pkgs.nix-prefetch-git} --url "https://github.com/$owner/styx-theme-$theme.git" --rev "$rev" --no-deepClone --quiet | jq -r '.sha256')"
            cat <<EOF >> "$target"
            $theme = {
              owner  = "$owner";
              repo   = "styx-theme-$theme";
              rev    = "$rev";
              sha256 = "$hash";
            };
          EOF
          done < "$source"

          echo "}" >> "$target"
        '';
      in
      {
        packages = { inherit styx report showcase update-doc update-themes; default = styx;};
        hydraJobs = { inherit styx; };

        inherit lib;

        checks = with (utils.lib.check-utils system);
          main-tests // {
            lib-tests = isEqual "lib-tests-${toString lib-tests.success}" "lib-tests-1";
            # doc-test = isEqual "
          };
      }
    );

}
