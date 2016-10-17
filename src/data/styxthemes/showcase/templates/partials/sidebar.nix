{ lib, templates, pages, data, ... }:
with lib;
''
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
      ${mapTemplate templates.post.list (take 5 pages.posts)}
      </ul>
    </section>
    ''}
  </div>
''
