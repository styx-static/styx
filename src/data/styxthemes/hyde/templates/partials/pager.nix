{ lib, templates, ... }:
{ pages, index }:
with lib;
let
  prevHref = if (index > 1)
             then templates.purl (elemAt pages (index - 2))
             else "#";
  nextHref = if (index < (length pages))
             then templates.purl (elemAt pages index)
             else "#";
in
optionalString ((length pages) > 1)
''
  <div class="pagination">
    ${if (index == 1) then ''
    <span class="pagination-item previous">Previous</span>
    '' else ''
    <a href="${prevHref}" class="pagination-item previous">Previous</a>
    ''}
    ${if (index == (length pages)) then ''
    <span class="next pagination-item">Next</span>
    '' else ''
    <a href="${nextHref}" class="next pagination-item">Next</a>
    ''}
  </div>
''
