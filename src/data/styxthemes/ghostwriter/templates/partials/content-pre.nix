{ templates, lib, conf, data, pages, ... }:
{ page }:
with lib;
''
<div id="wrapper">
<header class="site-header">
<div class="container">
<div class="site-title-wrapper">
<h1 class="site-title">
<a title="${conf.theme.site.title}" href="${templates.url "/"}">${conf.theme.site.title}</a>
</h1>

<!-- rss -->
${optionalString (pages ? feed) ''
<a class="button-square" href="${templates.url pages.feed}"><i class="fa fa-rss"></i></a>
 ''}

${optionalString (conf.theme.social.twitter != null) ''
<a class="button-square button-social hint--top" data-hint="Twitter" title="Twitter" href="${conf.theme.social.twitter}">
  <i class="fa fa-twitter"></i>
</a>
''}

${optionalString (conf.theme.social.gitlab != null) ''
<a class="button-square button-social hint--top" data-hint="Gitlab" title="Gitlab" href="${conf.theme.social.gitlab}">
  <i class="fa fa-gitlab"></i>
</a>
''}


${optionalString (conf.theme.social.github != null) ''
<a class="button-square button-social hint--top" data-hint="Github" title="Github" href="${conf.theme.social.github}">
  <i class="fa fa-github-alt"></i>
</a>
''}


${optionalString (conf.theme.social.stack-overflow != null) ''
<a class="button-square button-social hint--top" data-hint="Stack Overflow" title="Stack Overflow" href="${conf.theme.social.stack-overflow}">
  <i class="fa fa-stack-overflow"></i>
</a>
''}


${optionalString (conf.theme.social.linked-in != null) ''
<a class="button-square button-social hint--top" data-hint="LinkedIn" title="LinkedIn" href="${conf.theme.social.linked-in}">
  <i class="fa fa-linkedin"></i>
</a>
''}


${optionalString (conf.theme.social.google-plus != null) ''
<a class="button-square button-social hint--top" data-hint="Google+" title="Google+" href="${conf.theme.social.google-plus}">
  <i class="fa fa-google-plus"></i>
</a>
''}

${optionalString (conf.theme.social.email != null) ''
<a class="button-square button-social hint--top" data-hint="Email" title="Email" href="mailto:${conf.social.email}">
  <i class="fa fa-envelope"></i>
</a>
''}

</div>

${optionalString ((data ? menu) && (isList data.menu) && (length (data.menu) > 0)) ''
<ul class="site-nav">
${mapTemplate (menu: ''
<li class="site-nav-item">${templates.tag.ilink { to = menu; content = menu.title; title = menu.title; }}</li>
'') data.menu}
</ul>
''}
</header>
''
