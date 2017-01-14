{ lib, templates, ... }:
page:
with lib;

optionalString (page ? tags) (
  
  "<p>${templates.icon.font-awesome "tags"} "

  # generating links separated by /
+ concatMapStringsSep " / " (d:
    templates.tag.ilink {
      path    = d.path;
      content = d.term;
    })
  # get the tags a list of attribute sets with some data set
  (templates.taxonomy.value.term-list { inherit page; taxonomy = "tags"; })

+ "</p>"
)
