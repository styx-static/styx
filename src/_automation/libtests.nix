{
  inputs,
  cell,
}:
/*

Library Test Battery
*/
let
  l = inputs.nixpkgs.lib // builtins;

  inherit (inputs) nixpkgs;
  inherit (inputs.cells.renderers) styxlib;
  inherit (inputs.cells.app.cli) styx;

  decls = styxlib.styxOptions;
  root = styxlib.conf.parseDecls {
    inherit decls;
    optionFn = o:
      o.default or null;
  };

  secondStageStyxlib = styxlib.hydrate (_: _: {config = root;});

  libs =
    map (x:
      l.mapAttrs' (k: v: {
        name = "lib.${x}.${k}";
        value = v;
      })
      secondStageStyxlib."${x}")
    [
      "conf"
      "data"
      "generation"
      "pages"
      "proplist"
      "template"
      "themes"
      "utils"
    ];

  runTests =
    l.fold (
      test: acc:
        if test.code == test.expected
        then (acc // {success = acc.success ++ [test];})
        else (acc // {failures = acc.failures ++ [test];})
    ) {
      success = [];
      failures = [];
    };

  mkLoadFileTest = file: let
    data = secondStageStyxlib.data.loadFile {
      inherit file;
      env = {
        lib = secondStageStyxlib;
        foo = "bar";
        bar = [1 2 3];
        buz = 2;
      };
    };
    cleanData = l.removeAttrs data ["fileData"];
  in
    l.mapAttrs (
      k: v:
        if k == "pages"
        then map (x: l.removeAttrs x ["fileData"]) v
        else v
    )
    cleanData;

  customTests = [
    {
      name = "loadFile - markdown";
      function = "lib.data.loadFile";
      code = mkLoadFileTest ./tests/data/markdown.md;
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
    }
  ];
in rec {
  functions = l.fold (x: acc: acc // x) {} libs;

  tests = let
    ex = l.mapAttrsToList (name: fn: let
      extract =
        l.imap (
          index: ex:
            l.optionalAttrs (ex ? code && ex ? expected)
            (ex // {inherit name index;})
        )
        fn.examples;
    in
      if fn ? examples
      then extract
      else {})
    functions;
  in
    l.filter (x: x != {}) (l.flatten ex) ++ customTests;

  missingTests = let
    missing = l.mapAttrsToList (name: fn: let
      hasTest = l.any (ex: ex ? expected);
    in
      if styxlib.utils.isDocFunction fn
      then
        if fn ? examples && hasTest fn.examples
        then null
        else name
      else null)
    functions;
  in
    l.filter (x: x != null) (l.flatten missing);

  results = runTests tests;
}
