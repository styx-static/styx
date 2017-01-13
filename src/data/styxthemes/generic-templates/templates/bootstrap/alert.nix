env:
{ type ? "info"
, content }:
''
<div class="alert alert-${type}" role="alert">
${content}
</div>''
