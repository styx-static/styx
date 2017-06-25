/* Custom index page
   
   Returns a page attribute set, merge the data and the template for improved flexibility
*/
{ conf, templates, lib, ... }:
with lib;
let
  /* Page data 
     Can be customized to fit needs
  */
  name = "MR STYX";
  description = ''
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis non sollicitudin felis, vel sollicitudin nulla. Nunc ut quam sed lacus consectetur varius sit amet ultrices lacus. Maecenas quis mi consectetur, consequat nisl et, posuere ex. Proin porttitor justo diam. Nulla nec dui id nunc vehicula tincidunt sit amet egestas risus. Nunc semper odio vitae consequat feugiat. Integer congue vel turpis et accumsan. Aliquam felis nunc, pretium ullamcorper orci ut, lobortis mattis eros. Suspendisse potenti. Fusce ac aliquet enim. Duis pretium, magna ac facilisis blandit, lorem lacus commodo nulla, fringilla gravida magna eros a purus. Vivamus pellentesque laoreet ornare. Sed iaculis laoreet nisi vitae vestibulum. Cras ut viverra mi, ullamcorper pulvinar elit. Sed placerat magna at leo auctor, vitae porttitor libero suscipit.
  '';
  social = [ {
    title = "Twitter";
    icon  = "twitter";
    link  = "https://twitter.com/me";
  } {
    title = "GitHub";
    icon  = "github";
    link  = "https://github.com/me";
  } {
    title = "Email";
    icon  = "envelope";
    link  = "mailto:foo@bar.com";
  } ];

  /* template
  */
  content = ''
    <div class="row">
    	<div class="col-sm-3 col-centered">
    		<img alt="profile-picture" class="img-responsive img-circle user-picture" src="${templates.url "/images/profile.jpg"}">
    	</div>
    </div>
    <div class="row">
    	<div class="col-xs-12 user-profile text-center">
    		<h1 id="user-name">${name}</h1>
    	</div>
    </div>
    <div class="row">
    	<div class="col-xs-12 user-social text-center">
        ${mapTemplate (s: ''
          <a href="${s.link}" title="${s.title}"><i class="fa fa-${s.icon} fa-3x" aria-hidden="true"></i></a>
        '') social}
    	</div>
    </div>
    <div class="row">
    	<div class="col-md-4 col-md-offset-4 user-description text-center">
    		<p>${description}</p>
    	</div>
    </div>
  '';
in
  { inherit content; }
