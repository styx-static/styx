{ lib, templates, conf, data, ... }:
with lib;
page:
let
  draftIcon = optionalString (attrByPath ["isDraft"] false page) (templates.icon.bs "file");
  content = ''
    <article class="full">

      <div class="banner" ${optionalString (page ? banner) (htmlAttr "style" "background-image: url(${conf.siteUrl}/${page.banner});")}>
      </div>
      <header class="post-header">
        <h1>${draftIcon}${page.title}</h1>
      </header>

      <div class="meta text-muted">
        <p>
          ${templates.icon.fa "calendar-o"}
          <time pubdate="pubdate" datetime="${page.date}">${with (parseDate page.date); "${D} ${b} ${Y}"}</time>
        </p>
        ${templates.taxonomy.inline { inherit page; taxonomy = "tags"; title = templates.icon.fa "tags"; sep = " / "; }}
      </div>

      <div class="content">
        ${page.content}
      </div>

      ${optionalString (page ? pages) (templates.partials.pagination { pages = page.pages; index = page.index; })}

    </article>
  '';
in
  page // { inherit content; }
