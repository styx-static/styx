{ lib, templates, ... }:
with lib;
normalTemplate (page: ''
<div class="container">
  <article class="post-container post page" itemscope="" itemtype="http://schema.org/BlogPosting">
    <header class="post-header">
      <h1 class="post-title">${page.title}</h1>
    </header>
    <div class="post-content clearfix" itemprop="articleBody">
      ${page.content}

      ${optionalString (page ? pages) (templates.partials.pager { inherit (page.pages) pages index; })} 
    </div>
  </article>
</div>
'')
