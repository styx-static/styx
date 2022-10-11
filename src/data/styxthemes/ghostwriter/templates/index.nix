{
  conf,
  lib,
  templates,
  ...
}:
with lib;
  normalTemplate (page: ''
    <div id="post-index" class="container" itemscope="" itemtype="https://schema.org/Blog">

    <header class="post-header">
    <h1 class="post-title" itemprop="name">${conf.theme.site.title}</h1>
    ${optionalString (conf.theme.site.description != null) "<p>${conf.theme.site.description}</p>"}
    </header>

    <ol class="post-list">
    ${mapTemplate templates.post.list (page.items or [])}
    </ol>

    ${optionalString (page ? pages) (templates.partials.pager {
      inherit (page) pages index;
      prevText = "Newer Posts";
      nextText = "Older Posts";
    })}
    </div>
  '')
