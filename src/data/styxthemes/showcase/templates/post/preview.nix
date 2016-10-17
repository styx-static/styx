{ conf, lib, templates, ... }:
with lib;
page:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false page) "<span class=\"glyphicon glyphicon-file\"></span> ";
in
  ''
    <article class="preview col-md-6">
      <a href="${conf.siteUrl}/${page.href}" class="banner" ${optionalString (page ? banner) (htmlAttr "style" "background-image: url(${conf.siteUrl}/${page.banner});")})>
      </a>
      <header><a href="${conf.siteUrl}/${page.href}">${draftIcon}${page.title}</a></header>
      <div class="meta text-muted">
        <p>
          ${templates.icon.fa "calendar-o"}
          <time pubdate="pubdate" datetime="${page.date}">${with (parseDate page.date); "${D} ${b} ${Y}"}</time>
        </p>
        ${templates.taxonomy.inline { inherit page; taxonomy = "tags"; title = templates.icon.fa "tags"; sep = " / "; }}
      </div>

      ${optionalString (page ? intro) page.intro}
    </article>
  ''
