{ conf, lib, ... }:
with lib;
''
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml xml:lang="${conf.theme.site.languageCode}" lang="${conf.theme.site.languageCode}">
<head>
  <link href="http://gmpg.org/xfn/11" rel="profile">
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  ${generatorMeta}

  <!-- Enable responsiveness on mobile devices-->
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">

  <title>${conf.theme.site.title}</title>

  <!-- CSS -->
  <link rel="stylesheet" href="${conf.siteUrl}/css/poole.css">
  <link rel="stylesheet" href="${conf.siteUrl}/css/syntax.css">
  <link rel="stylesheet" href="${conf.siteUrl}/css/hyde.css">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=PT+Sans:400,400italic,700|Abril+Fatface">

  <!-- Icons -->
  <link rel="apple-touch-icon-precomposed" sizes="144x144" href="/apple-touch-icon-144-precomposed.png">
  <link rel="shortcut icon" href="/favicon.png">

  <!-- RSS -->
</head>
''
