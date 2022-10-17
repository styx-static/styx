{lib, ...}: page: ''
  <div class="sidebar-wrapper">
  ${(lib.template.processBlocks page."sidebar-blocks").content}
  </div><!--//sidebar-wrapper-->
''
