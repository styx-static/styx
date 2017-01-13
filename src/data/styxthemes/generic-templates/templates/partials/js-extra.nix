/* This template allow to add custom javacript file per page attribute set.
   If a page defines a `extraJS` attribute, its contents will be loaded here

   extraJS should be a list of attribute set in the followong format:

     [ { src = "..."; } ]

   Any extra attribute to the list will be added as a html attribute to the script tag
*/
{ lib, templates, ... }:
{ page }:
with lib;
optionalString (page ? extraJS)
  (mapTemplate templates.tag.script page.extraJS)
