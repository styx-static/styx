{ templates, ... }:
page:
''
<!DOCTYPE html>
  ${templates.partials.lang}
<head>
  ${templates.partials.head}
</head>
<body>
  <div class="wrapper">
    ${templates.partials.sidebar}
	  <div class="main-wrapper">
      ${templates.partials.summary}
      ${templates.partials.experiences}
      ${templates.partials.projects}
      ${templates.partials.skills}
	  </div><!--//main-body-->
  </div>
  ${templates.partials.footer}
  ${templates.partials.js}
</body>
</html> 
''
