{ conf, ... }:
''
<title>${conf.theme.site.title}</title>
<!-- Meta -->
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="${conf.theme.site.description}">
<meta name="author" content="${conf.theme.site.author}">    
<link rel="shortcut icon" href="favicon.ico">  
<link href='https://fonts.googleapis.com/css?family=Roboto:400,500,400italic,300italic,300,500italic,700,700italic,900,900italic' rel='stylesheet' type='text/css'>
<!-- Global CSS -->
<link rel="stylesheet" href="${conf.siteUrl}/assets/plugins/bootstrap/css/bootstrap.min.css">   
<!-- Plugins CSS -->
<link rel="stylesheet" href="${conf.siteUrl}/assets/plugins/font-awesome/css/font-awesome.css">

<!-- Theme CSS -->  
<link id="theme-style" rel="stylesheet" href="${conf.siteUrl}/assets/css/styles-${toString conf.theme.colorScheme}.css">
<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
<!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->
''
