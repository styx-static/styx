{ lib, ... }:
{ heading ? null
, body    ? null
, footer  ? null
, content ? null
, type    ? "default" }:
with lib;
''
<div class="panel panel-${type}">
  ${optionalString (heading != null) ''<div class="panel-heading">${heading}</div>''}
  ${optionalString (body    != null) ''<div class="panel-body">${body}</div>''}
  ${optionalString (content != null) content}
  ${optionalString (footer  != null) ''<div class="panel-footer">${footer}</div>''}
</div>''
