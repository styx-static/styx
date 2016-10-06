/* NavBar template, take one parameter:

   - navbar: A list of pages to include in the NavBar. (Pages must have a `title` attribute set)
   - index: The current page index

   Usage example in the base template function:

     templates.navbar.main navbar

*/
{ templates, lib, conf, ... }:
navbar:
with lib;
''
<nav class="navbar navbar-fixed-top">
  <div class="container">

    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      ${templates.navbar.brand}
    </div>

    <div class="collapse navbar-collapse" id="navbar">
      <ul class="nav navbar-nav">
        ${mapTemplate (item:
        ''
          <li><a ${htmlAttr "href" (if (isExternalHref item.href) then "${item.href}" else "${conf.siteUrl}/${item.href}")}>${item.title}</a></li>
        '') navbar}
      </ul>
    </div>

  </div>
</nav>
''
