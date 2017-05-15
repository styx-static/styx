{ lib, templates, ... }:
{ pages, index, prevText ? "Previous Page", nextText ? "Next Page" }:
with lib;
optionalString ((length pages) > 1)
''
<nav class="pagination" role="navigation">
  <span class="page-number">Page ${toString index} of ${toString (length pages)}</span>
  ${optionalString (index > 1) ''
      <a class="newer-posts" href="${templates.url (elemAt pages (index - 2))}">&larr; ${prevText}</a>
  ''}
  ${optionalString (index < (length pages)) ''
      <a class="older-posts" href="${templates.url (elemAt pages index)}">${nextText} &rarr;</a>
  ''}
</nav>
''
