{
  conf,
  templates,
  lib,
  ...
}:
with lib;
  normalTemplate (
    page: let
      postsByYear = groupBy page.items (d: (parseDate d.date).Y);
    in ''
      <h1>${page.title}${optionalString (page.index > 1) " - ${toString page.index}"}</h1>

      ${mapTemplate (prop: let
          year = proplist.propKey prop;
          items = proplist.propValue prop;
        in ''
          <section>
          <h2>${year}</h2>
          <ul>
            ${mapTemplate templates.post.list items}
          </ul>
          </section>
        '')
        postsByYear}

      ${templates.bootstrap.pagination {inherit (page) pages index;}}
    ''
  )
