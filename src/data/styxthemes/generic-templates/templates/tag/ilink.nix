/* internal link template
   can be passed a path or a page attribute set
*/
{ conf, templates, ... }:
{ path ? null
, page ? null
, tag ? "a"
, ...
}@args:
let href = if path != null
           then templates.url path
           else templates.purl page;
in
templates.tag.generic ((removeAttrs args [ "path" "page" ]) // {
  inherit tag href;
})
