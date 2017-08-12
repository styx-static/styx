{  lib, ... }:
page:
''
<div class="sidebar-wrapper">
${(lib.processBlocks page."sidebar-blocks").content}
</div><!--//sidebar-wrapper-->
''
