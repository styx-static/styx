{ templates, lib, ... }:
{ page, ... }:
''
<div class="wrapper">
${templates.partials.sidebar page}
<div class="main-wrapper">
''
