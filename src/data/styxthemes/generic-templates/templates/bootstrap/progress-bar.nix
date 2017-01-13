{ lib, ... }:
{ type ? null
, value }:
with lib;
let extraClass = if type == null
                 then ""
                 else " progress-bar-${type}";
in
''
<div class="progress">
  <div class="progress-bar${extraClass}" role="progressbar" aria-valuenow="${toString value}" aria-valuemin="0" aria-valuemax="100" style="width: ${toString value}%"><span class="sr-only">${toString value}% Complete</span></div>
</div>
''
