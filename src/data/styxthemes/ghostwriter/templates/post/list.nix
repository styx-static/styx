{
  conf,
  lib,
  templates,
  ...
}:
with lib;
  page: ''
    <li class="post-stub" itemprop="blogPost" itemscope="" itemtype="https://schema.org/BlogPosting">
      <a href="${templates.url page}" itemprop="url" title="Go to post detail">
        <h4 class="post-stub-title" itemprop="name">${page.title}</h4>
        <time class="post-stub-date" datetime="${(parseDate page.date).date.num}">Published ${with (parseDate page.date); "${b} ${D}, ${YYYY}"}</time>
      </a>
    </li>
  ''
