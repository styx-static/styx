{
  lib,
  templates,
  conf,
  data,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (
    page: ''
      <article class="full">

        <div class="banner" ${optionalString (page ? banner) (lib.template.htmlAttr "style" "background-image: url(${templates.url page.banner});")}>
        </div>
        <header class="post-header">
          <h1>${templates.post.draft-icon page}${page.title}</h1>
        </header>

        <div class="meta text-muted">
          <p>
            ${templates.icon.font-awesome "calendar-o"}
            <time datetime="${(lib.template.parseDate page.date).T}">${with (lib.template.parseDate page.date); "${D} ${b} ${Y}"}</time>
          </p>
          ${templates.post.tags-inline page}
        </div>

        <div class="content">
          ${page.content}
        </div>

        ${optionalString (page ? multipages) (templates.bootstrap.pagination {inherit (page.multipages) pages index;})}

        ${optionalString (page ? pageList) (
        "<hr />"
        + (templates.bootstrap.pager {inherit (page.pageList) pages index;})
      )}

      </article>
    ''
  )
