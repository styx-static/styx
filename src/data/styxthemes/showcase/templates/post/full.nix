{ lib, templates, conf, data, ... }:
with lib;
normalTemplate (page:
  ''
    <article class="full">

      <div class="banner" ${optionalString (page ? banner) (htmlAttr "style" "background-image: url(${templates.url page.banner});")}>
      </div>
      <header class="post-header">
        <h1>${templates.post.draft-icon page}${page.title}</h1>
      </header>

      <div class="meta text-muted">
        <p>
          ${templates.icon.font-awesome "calendar-o"}
          <time datetime="${(parseDate page.date).T}">${with (parseDate page.date); "${D} ${b} ${Y}"}</time>
        </p>
        ${templates.post.tags-inline page}
      </div>

      <div class="content">
        ${page.content}
      </div>

      ${optionalString (page ? pages) (templates.bootstrap.pagination { inherit (page) pages index; })}

    </article>
  ''
)
