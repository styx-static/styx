/* This template allow to add custom css file per page attribute set.
   If a page defines a `extraCSS` attribute, its contents will be loaded here

   extraCSS should be a list of attribute set in the followong format:

     [ { href = "..."; } ]

   Any extra attribute to the list will be added as a html attribute to the link tag
*/
{ lib, templates, ... }:
{ page }:
with lib;
optionalString (page ? extraCSS)
  (mapTemplate templates.tag.link-css page.extraCSS)
