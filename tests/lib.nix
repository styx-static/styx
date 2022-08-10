/* Library tests for Styx

   To see the tests report run:

     cat $(nix-build --no-out-link -A report tests/lib.nix)

   To check test coverage run:

     cat $(nix-build --no-out-link -A coverage tests/lib.nix)

*/
let
  pkgs = import ../nixpkgs;
  lib  = (import pkgs.styx {}).lib;
in with lib;
let
  namespaces = [
    "conf"
    "data"
    "generation"
    "pages"
    "proplist"
    "template"
    "themes"
    "utils"
  ];

  libs = map (x:
    mapAttrs' (k: v:
      { name = "lib.${x}.${k}"; value = v; }
    ) lib."${x}"
  ) namespaces;

  functions = fold (x: acc:
    acc // x
  ) {} libs;

  tests =
    let
      ex = mapAttrsToList (name: fn:
        let
          extract = imap (index: ex:
            optionalAttrs (ex ? code && ex ? expected)
            (ex // { inherit name index; })
          ) fn.examples;
        in if fn ? examples then extract else {}) functions;
    in (filter (x: x != {}) (flatten ex) ++ customTests);

   missingTests =
    let
      missing = mapAttrsToList (name: fn:
        let
          hasTest = any (ex: ex ? expected);
        in if   isDocFunction fn
           then if   docFn ? examples && hasTest docFn.examples
                then null
                else name
           else null) functions;
    in filter (x: x != null) (flatten missing);

   runTests = fold (test: acc:
     if test.code == test.expected
     then (acc // { success  = acc.success ++ [ test ]; })
     else (acc // { failures = acc.failures ++ [ test ]; })
   ) { success = []; failures = []; };

   results = runTests tests;

   successNb  = length results.success;
   failuresNb = length results.failures;

   lsep  = "====================\n";
   sep   = "---\n";
   inSep = x: sep + x + sep;

   report = pkgs.writeText "lib-tests-report.txt" ''
     ---
     ${toString (successNb + failuresNb)} tests run.
     - ${toString successNb} success(es).
     - ${toString failuresNb} failure(s).
     ${optionalString (failuresNb > 0) ''

     Failures details:

     ${lsep}${mapTemplate (failure:
       let
         header = "${failure.name}${optionalString (failure ? index) ", example number ${toString failure.index}"}:\n";
         code = optionalString (failure ? literalCode) ("\ncode:\n" + inSep failure.literalCode);
         expected = "\nexpected:\n" + inSep "${prettyNix failure.expected}\n";
         got = "\ngot:\n" + inSep "${prettyNix failure.code}\n";
       in
         header + code + expected + got + lsep
     ) results.failures}''}
     ---
     '';

   coverage = pkgs.writeText "lib-tests-coverage.txt" ''
     ---
     ${toString (length missingTests)} functions missing tests:

     ${mapTemplate (f: " - ${f}") missingTests}
     ---
   '';

   mkLoadFileTest = file:
     let data = loadFile { inherit file; env = { inherit lib; foo = "bar"; bar = [1 2 3]; buz = 2; }; };
         cleanData = removeAttrs data [ "fileData" ];
     in mapAttrs (k: v:
       if   k == "pages"
       then map (x: removeAttrs x [ "fileData" ]) v
       else v
     ) cleanData;

   customTests = [ {
     name = "loadFile - markdown";
     function = "lib.data.loadFile";
     code = mkLoadFileTest ./data/markdown.md;
     expected = {
       bar = "answer";
       baz = 40;
       foo = "The answer";
       intro = ''
         <p>Intro text.</p>
       '';
       pages = [
         {
           content = ''
             <p>First page</p>
     
             <p>The answer is 42.</p>
           '';
         }
         {
           content = ''
             <p>Second page.</p>
     
             <p>{{ non evaluated nix }}</p>
     
             <p>this }} is not evaluated</p>
           '';
         }
         {
           content = ''
             <p>Third page.</p>
           '';
         }
       ];
     };
   } ];

in {
  inherit failures report results functions tests coverage;
  success = failuresNb == 0;
}
