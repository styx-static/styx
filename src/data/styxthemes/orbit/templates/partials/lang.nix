{ conf, ... }:
''
<!--[if IE 8]> <html lang="{{ with .Site.LanguageCode }}{{ . }}{{ else }}en-US{{ end }}" class="ie8"> <![endif]-->  
<!--[if IE 9]> <html lang="{{ with .Site.LanguageCode }}{{ . }}{{ else }}en-US{{ end }}" class="ie9"> <![endif]-->  
<!--[if !IE]><!--> <html lang="{{ with .Site.LanguageCode }}{{ . }}{{ else }}en-US{{ end }}"> <!--<![endif]-->
''
