{ lib, ... }:
content:
with lib;
''
<span class="badge">${toString content}</span>
''
