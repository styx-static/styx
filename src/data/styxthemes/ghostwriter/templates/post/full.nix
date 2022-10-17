{
  lib,
  templates,
  ...
}:
with lib.lib;
  lib.template.normalTemplate (page: ''
    <div class="container">
      <article class="post-container" itemscope="" itemtype="http://schema.org/BlogPosting">
        <header class="post-header">
          <h1 class="post-title" itemprop="name headline">${page.title}</h1>
          ${optionalString (page ? intro) ''
      <p class="post-description" itemprop="description">${page.intro}</p>
    ''}
          <p class="post-date">
            <span>Published <time datetime="${(lib.template.parseDate page.date).date.num}" itemprop="datePublished">${with (lib.template.parseDate page.date); "${b} ${D}, ${YYYY}"}</time></span>
            ${optionalString (page ? author) ''
      <span>by</span>
      <span itemscope="" itemprop="author" itemtype="https://schema.org/Person">
        <span itemprop="name">
          ${
        if (page.author ? url)
        then ''<a href="${page.author.url}" itemprop="url" rel="author">${page.author.name}</a>''
        else page.author.name
      }
        </span>
      </span>
    ''}
          </p>
        </header>

        <div class="post-content clearfix" itemprop="articleBody">
          ${page.content}

          ${optionalString (page ? multipages) (templates.partials.pager {inherit (page.multipages) pages index;})}
        </div>
      </article>
    </div>
  '')
