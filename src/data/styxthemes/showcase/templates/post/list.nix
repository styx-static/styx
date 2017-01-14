{ conf, lib, templates, ... }:
with lib;
page:
''
  <li>
    <a href="${templates.url page.path}">${templates.post.draft-icon page}${page.title}</a>
  </li>
''
