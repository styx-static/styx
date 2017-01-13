{ templates, ... }:
args:
''
<body>
${(templates.partials.content-pre  args)
+ (templates.partials.content      args)
+ (templates.partials.content-post args)
+ (templates.partials.js args)
}</body>
''
