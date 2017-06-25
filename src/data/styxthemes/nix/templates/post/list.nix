{ conf, lib, templates, ... }:
with lib;
page:
''
  <li>
  	<div class="post-list-item">
  		<div class="post-header">
  			<h4 class="post-link">${templates.tag.ilink { to = page; }}</h4>
  			<h4 class="post-date">${with (parseDate page.date); "${D} ${b}, ${Y}"}</h4>
  		</div>
      ${optionalString (page ? intro) ''
        <div class="post-summary">${page.intro}
      ''}
  		<div class="post-list-footer text-center">
        ${templates.tag.ilink { to = page; content = "Read more"; }}
  		</div>
  	</div>
  </li>
''
