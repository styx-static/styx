{ lib, templates, conf, ... }:
with lib;
post:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false post) "<span class=\"glyphicon glyphicon-file\"></span> ";
  content = ''
    <div class="post">

      <header class="post-header">
        <div class="text-center">
          <time pubdate="pubdate" datetime="${post.date}">${draftIcon}${with (parseDate post.date); "${D} ${b} ${Y}"}</time>
        </div>
      </header>

      ${templates.taxonomy.inline { taxonomy = "tags"; page = post; }}
      ${templates.taxonomy.inline { taxonomy = "categories"; page = post; }}

      <article class="post-content">
        ${post.content}
      </article>

    </div>
  '';
in
  post // { inherit content; }
