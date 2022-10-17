env: let
  template = {
    conf,
    lib,
    templates,
    ...
  }: page:
    with lib.lib; ''
      <entry>
        <id>${templates.url page}</id>
        <title>${page.title}</title>
        <updated>${(lib.template.parseDate page.date).T}</updated>
        <link href="${templates.url page}" rel="alternate" type="text/html"/>
        ${optionalString (page ? intro) ''        <summary type="xhtml">
              <div xmlns="http://www.w3.org/1999/xhtml">
                ${page.intro}
              </div>
            </summary>''}
        ${optionalString (page ? content) ''        <content type="xhtml">
              <div xmlns="http://www.w3.org/1999/xhtml">
                ${page.content}
              </div>
            </content>''}
      </entry>
    '';
in
  env.lib.template.documentedTemplate {
    description = ''
      Template generating an Atom feed entry. +
      Used in `templates.feed.atom`.
    '';
    inherit env template;
  }
