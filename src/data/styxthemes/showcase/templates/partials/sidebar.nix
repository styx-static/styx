{
  lib,
  templates,
  pages,
  data,
  ...
}:
with lib.lib; ''
  <div class="sidebar">
    ${optionalString (data ? taxonomies) ''
    <section>
      <h2>Taxonomies</h2>
      ${templates.taxonomy.full-section data.taxonomies.posts}
    </section>
  ''}
    ${optionalString (pages ? posts) ''
    <section>
      <h2>Recent Posts</h2>
      <ul>
      ${lib.template.mapTemplate templates.post.list (take 5 pages.posts.list)}
      </ul>
    </section>
  ''}
  </div>
''
