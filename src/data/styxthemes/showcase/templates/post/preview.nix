{
  conf,
  lib,
  templates,
  ...
}:
with lib.lib;
  page: ''
    <article class="preview col-md-6">
      <a href="${templates.url page.path}" class="banner" ${optionalString (page ? banner) (lib.template.htmlAttr "style" "background-image: url(${templates.url page.banner});")}>
      </a>
      <header><h2><a href="${templates.url page.path}">${templates.post.draft-icon page}${page.title}</a></h2></header>
      <div class="meta text-muted">
        <p>
          ${templates.icon.font-awesome "calendar-o"}
          <time datetime="${(lib.template.parseDate page.date).T}">${with (lib.template.parseDate page.date); "${D} ${b} ${Y}"}</time>
        </p>
        ${templates.post.tags-inline page}
      </div>

      ${optionalString (page ? intro) page.intro}
    </article>
  ''
