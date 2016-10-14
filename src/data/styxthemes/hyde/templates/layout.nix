{ conf, lib, templates, data, ... }:
page:
with lib;
''
${templates.partials.head}
<body class="${conf.theme.color or ""}${optionalString conf.theme.layout-reverse "  layout-reverse"}">

  ${templates.partials.sidebar}

  <div class="content container">
  ${page.content}
  </div>

</body>
</html>
''
