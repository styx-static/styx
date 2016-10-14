{ conf, ... }:
page:
let content =
''
  <h1>404: Page not found</h1>
  <p class="lead">Sorry, we've misplaced that URL or it's pointing to something that doesn't exist. <a href="${conf.siteUrl}">Head back home</a> to try finding it again.</p>
'';
in
  page // { inherit content; }
