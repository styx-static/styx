{ conf, lib, templates, ... }:
with lib;
''
<footer class="footer">
  <div class="text-center">
  <!--/* This template is released under the Creative Commons Attribution 3.0 License. Please keep the attribution link below when using for your own project. Thank you for your support. :) If you'd like to use the template without the attribution, you can check out other license options via our website: themes.3rdwavemedia.com */-->
  <small class="copyright">Designed with ${templates.icon.fa "heart"} by <a href="http://themes.3rdwavemedia.com" target="_blank">Xiaoying Riley</a> for developers</small><br>
	<small class="copyright">2016 &copy; ${conf.theme.copyright}</small>
  </div><!--//container-->
</footer><!--//footer-->
''
