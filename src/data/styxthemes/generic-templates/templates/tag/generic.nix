/* generic template for a tag
   
   templates.tag.generic { tag = "div"; content = "hello world" }
*/
{ lib, ... }:
{ tag ? "div", content, ... }@args:
with lib;
let
  attrs = htmlAttrs (removeAttrs args [ "tag" "content" ]);
in
  "<${tag} ${attrs}>${content}</${tag}>"
