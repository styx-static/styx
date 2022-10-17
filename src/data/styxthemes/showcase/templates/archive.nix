{
  conf,
  templates,
  lib,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (
    page: let
      postsByYear = lib.data.groupByFlatten page.items (d: (lib.template.parseDate d.date).Y);
    in ''
      <h1>${page.title}${optionalString (page.index > 1) " - ${toString page.index}"}</h1>

      ${lib.template.mapTemplate (prop: let
          year = lib.proplist.propKey prop;
          items = lib.proplist.propValue prop;
        in ''
          <section>
          <h2>${year}</h2>
          <ul>
            ${lib.template.mapTemplate templates.post.list items}
          </ul>
          </section>
        '')
        postsByYear}

      ${templates.bootstrap.pagination {inherit (page) pages index;}}
    ''
  )
