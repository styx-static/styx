{ conf, templates, ... }:
''
<div class="sidebar-wrapper">
  ${templates.partials.profile}
  ${templates.partials.contact}
  ${templates.partials.education}
  ${templates.partials.languages}
  ${templates.partials.interests}
</div><!--//sidebar-wrapper-->
''
