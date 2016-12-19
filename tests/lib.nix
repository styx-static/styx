/* Styx lib tests

   run with
   
     nix-instantiate --eval --strict --show-trace tests/lib.nix
*/
let
  pkgs = (import <nixpkgs> {});
  lib = pkgs.callPackage ../src/lib {};
in with lib;

runTests {

  /* Template
  */

  testHtmlAttr = {
    expr = htmlAttr "class" [ "foo" "bar" ];
    expected = "class=\"foo bar\"";
  };

  testIsExternalHref = {
    expr = isExternalHref "/test.html";
    expected = false;
  };

  testMapTemplate = {
    expr = mapTemplate (i: "<li>${i}</li>") [ "foo" "bar" ];
    expected = ''
      <li>foo</li>
      <li>bar</li>'';
  };

  testMapTemplateWithIndex = {
    expr = mapTemplateWithIndex (index: item: "<li>${toString index} - ${item}</li>") [ "foo" "bar" ];
    expected = ''
      <li>1 - foo</li>
      <li>2 - bar</li>'';
  };

  testMod = {
    expr = mod 3 2;
    expected = 1;
  };

  testIsEven = {
    expr = isEven 3;
    expected = false;
  };

  testIsOdd = {
    expr = isOdd 3;
    expected = true;
  };

  testParseDate = {
    expr = with (parseDate "2012-12-21"); "${D} ${b} ${Y}";
    expected = "21 Dec 2012";
  };


  /* Data
  */

  testSortTerms = {
    expr = sortTerms [ { b = [1 2]; } { a = [1]; } { c = [1 2 3]; } ];
    expected = [ { c = [ 1 2 3 ]; } { b = [ 1 2 ]; } { a = [ 1 ]; } ];
  };

  testValuesNb = {
    expr = valuesNb { c = [1 2 3]; };
    expected = 3;
  };

  /* Pages
  */

  testMkSplit = {
    expr = mkSplit {
      baseHref = "/test";
      itemsPerPage = 2;
      data = range 1 4;
    };
    expected = let 
      pages = [ { href = "/test.html";   index = 1; items = [ 1 2 ]; itemsNb = 2; }
                { href = "/test-2.html"; index = 2; items = [ 3 4 ]; itemsNb = 2; } ];
      in map (p: p // { inherit pages; }) pages;
  };

  /* Generation
  */

  testPagesToList = {
    expr = pagesToList {
      pages = { a = { title = "foo"; }; b = [ { title = "bar"; } { title = "baz"; } ]; } ;
      default = { layout = "test"; };
    };
    expected = [
      { layout = "test"; title = "foo"; }
      { layout = "test"; title = "bar"; }
      { layout = "test"; title = "baz"; }
    ];
  };

  /* Utils
  */

  testMerge = {
    expr = merge [ { a = 1; b.c = 1; x.y = 1; } { a = 2; b.c = 2; x.z = 2; } ];
    expected = { a = 2; b = { c = 2; }; x = { y = 1; z = 2; }; };
  };

  testChunksOf = {
    expr = chunksOf 2 [ 1 2 3 4 5 ];
    expected = [ [ 1 2 ] [ 3 4 ] [ 5 ] ];
  };

  testSetDefault = {
    expr = setDefault [ { foo = 1; } { bar = 2; } ] { foo = 0; bar = 0; };
    expected = [ { foo = 1; bar = 0; } { foo = 0; bar = 2; } ];
  };

  testSortBy = {
    expr = sortBy "priority" "asc" [ { priority = 5; } { priority = 2; } ];
    expected = [ { priority = 2; } { priority = 5; } ];
  };

  /* Proplist
  */

  testPropValue = {
    expr = propValue { name = "Alice"; };
    expected = "Alice";
  };

  testPropKey = {
    expr = propKey { name = "Alice"; };
    expected = "name";
  };

  testIsDefined = {
    expr = isDefined "name" [ { name = "Alice"; } { age = 26; } ];
    expected = true;
  };

  testGetValue = {
    expr = getValue "name" [ { name = "Alice"; } { age = 26; } ];
    expected = "Alice";
  };

  testGetProp = {
    expr = getProp "name" [ { name = "Alice"; } { age = 26; } ];
    expected = { name = "Alice"; };
  };

  testRemoveProp = {
    expr = removeProp "name" [ { name = "Alice"; } { age = 26; } ];
    expected = [ { age = 26; } ];
  };

  testPropFlatten = {
    expr = propFlatten [ { tags = [ "sports" "technology" ]; } { tags = [ "food" "trip" ]; } ];
    expected = [ { tags = [ "sports" "technology" "food" "trip" ]; } ];
  };

  testPropMap = {
    expr = propMap (p: v: "${p}: ${toString v}") [ { name = "Alice"; } { age = 26; } ];
    expected = [ "name: Alice" "age: 26" ];
  };

}
