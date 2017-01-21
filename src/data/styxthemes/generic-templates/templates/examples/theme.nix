{ lib, templates, data, ... }:
with lib;
let
  pageHeader = t: ''
    <div class="page-header">
      <h1>${t}</h1>
    </div>
  '';
in normalTemplate (page:

  /* required extra css
  */
  ''
  <style type="text/css">
  body {
    padding-top: 70px;
    padding-bottom: 30px;
  }
  .page-header:not(:first-child) {
    margin-top: 5em;
  }
  </style>
  ''

  /* In a normal site the navbar should be in templates.partials.content-pre
  */
+ templates.bootstrap.navbar.default {
    inverted = true;
    brand = ''<a class="navbar-brand" href="#">Styx Generic Templates</a>'';
    extraClasses = [ "navbar-fixed-top" ];
    content = [
      (templates.bootstrap.navbar.nav {
        items = data.navbar;
        currentPage = page;
      })
    ];
  } 

+ ''
    <div class="container">
      ${templates.bootstrap.alert { type = "info";
      content = "This page show the bootstrap components for which this theme provide helper templates."; } }
    </div>

    <div class="container theme-showcase" role="main">

      ${pageHeader "Glyphicons"}
      <h3>${templates.icon.bootstrap "picture"} ${templates.icon.bootstrap "tag"}</h3>
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = (escapeHTML "<h3>") + ''''${templates.icon.bootstrap "picture"} ''${templates.icon.bootstrap "tag"}'' + (escapeHTML "</h3>");
      }}

      ${pageHeader "Font Awesome icons"}
      <h3>${templates.icon.font-awesome "linux"} ${templates.icon.font-awesome "code"}</h3>
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = (escapeHTML "<h3>") + ''''${templates.icon.font-awesome "linux"} ''${templates.icon.font-awesome "code"}'' + (escapeHTML "</h3>");
      }}

      ${pageHeader "Breadcrumbs"}
      ${ # meant to be used with page attribute sets
      templates.bootstrap.breadcrumbs {
        breadcrumbs = [ { title = "Home"; path = "/index.thml"; } { title = "Library"; path = "/library/index.html"; } ];
        title = "Data";
      }}
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = ''
          templates.bootstrap.breadcrumbs {
            breadcrumbs = [ { title = "Home"; path = "/index.thml"; } { title = "Library"; path = "/library/index.html"; } ];
            title = "Data";
          }
        '';
      }}

      ${pageHeader "Pager"}
      ${templates.bootstrap.pager {
        pages = genList (x: { path = "/#${toString (x + 1)}"; }) 10;
        index = 5;
      }}
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = ''
          templates.bootstrap.pager {
            pages = genList (x: { path = "/#''${toString (x + 1)}"; }) 10;
            index = 5;
          }
        '';
      }}

      ${pageHeader "Pagination"}
      ${templates.bootstrap.pagination {
        pages = genList (x: { path = "/#${toString (x + 1)}"; }) 10;
        index = 5;
      }}
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = ''
          templates.bootstrap.pagination {
            pages = genList (x: { path = "/#''${toString (x + 1)}"; }) 10;
            index = 5;
          }
        '';
      }}

      ${pageHeader "Labels"}
      <h3>
        ${mapTemplate (t:
          templates.bootstrap.label { content = t; type = t; }
        ) [ "default" "primary" "success" "info" "warning" "danger" ]}
      </h3>
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = ''
          mapTemplate (t:
            templates.bootstrap.label { content = t; type = t; }
          ) [ "default" "primary" "success" "info" "warning" "danger" ]
        '';
      }}

      ${pageHeader "Badges"}
      <p>
        <a href="#">Inbox ${templates.bootstrap.badge 42}</a>
      </p>
      <ul class="nav nav-pills" role="tablist">
        <li role="presentation" class="active"><a href="#">Home ${templates.bootstrap.badge 42}</a></li>
        <li role="presentation"><a href="#">Profile</a></li>
        <li role="presentation"><a href="#">Messages ${templates.bootstrap.badge 3}</a></li>
      </ul>
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = escapeHTML ''
          <p>
           <a href="#">Inbox ''${templates.bootstrap.badge 42}</a>
          </p> 
          <ul class="nav nav-pills" role="tablist">
            <li role="presentation" class="active"><a href="#">Home ''${templates.bootstrap.badge 42}</a></li>
            <li role="presentation"><a href="#">Profile</a></li>
            <li role="presentation"><a href="#">Messages ''${templates.bootstrap.badge 3}</a></li>
          </ul>
        '';
      }}

      ${pageHeader "Navbars"}
      ''
+     templates.bootstrap.navbar.default {
        inverted = true;
        id = "example1";
        brand = ''<a class="navbar-brand" href="#">Project Name</a>'';
        content = [
          (templates.bootstrap.navbar.nav {
            items = [ 
              { title = "Home";    path = "/#"; }
              { title = "About";   path = "/#about"; }
              { title = "Contact"; path = "/#contact"; }
            ];
            # Hack for demonstration purposes, the current page attribute set should be passed
            currentPage = { title = "Home"; path = "/#"; };
          })
        ];
      } 

+     templates.bootstrap.navbar.default {
        brand = ''<a class="navbar-brand" href="#">Project Name</a>'';
        id = "example2";
        content = [
          (templates.bootstrap.navbar.nav {
            items = [ 
              { title = "Home";    path = "/#"; }
              { title = "About";   path = "/#about"; }
              { title = "Contact"; path = "/#contact"; }
            ];
            # Hack for demonstration purposes, the current page attribute set should be passed
            currentPage = { title = "Home"; path = "/#"; };
          })
        ];
      } 

+     ''
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = escapeHTML ''
          templates.bootstrap.navbar.default {
            inverted = true;
            id = "example1";
            brand = '''<a class="navbar-brand" href="#">Project Name</a>''';
            content = [
              (templates.bootstrap.navbar.nav {
                items = [ 
                  { title = "Home";    path = "/#"; }
                  { title = "About";   path = "/#about"; }
                  { title = "Contact"; path = "/#contact"; }
                ];
                # Hack for demonstration purposes, the current page attribute set should be passed
                currentPage = { title = "Home"; path = "/#"; };
              })
            ];
          } 
          +
          templates.bootstrap.navbar.default {
            brand = '''<a class="navbar-brand" href="#">Project Name</a>''';
            id = "example2";
            content = [
              (templates.bootstrap.navbar.nav {
                items = [ 
                  { title = "Home";    path = "/#"; }
                  { title = "About";   path = "/#about"; }
                  { title = "Contact"; path = "/#contact"; }
                ];
                # Hack for demonstration purposes, the current page attribute set should be passed
                currentPage = { title = "Home"; path = "/#"; };
              })
            ];
          } 
        '';
      }}


      ${pageHeader "Alerts"}
      ${templates.bootstrap.alert { type = "success"; content = "<strong>Well done!</strong> You successfully read this important alert message."; } }
      ${templates.bootstrap.alert { type = "info";    content = "<strong>Heads up!</strong> This alert needs your attention, but it's not super important."; } }
      ${templates.bootstrap.alert { type = "warning"; content = "<strong>Heads up!</strong> This alert needs your attention, but it's not super important."; } }
      ${templates.bootstrap.alert { type = "danger";  content = "<strong>Oh snap!</strong> Change a few things up and try submitting again."; } }
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = escapeHTML ''
          ''${templates.bootstrap.alert { type = "success"; content = "<strong>Well done!</strong> You successfully read this important alert message."; } }
          ''${templates.bootstrap.alert { type = "info";    content = "<strong>Heads up!</strong> This alert needs your attention, but it's not super important."; } }
          ''${templates.bootstrap.alert { type = "warning"; content = "<strong>Heads up!</strong> This alert needs your attention, but it's not super important."; } }
          ''${templates.bootstrap.alert { type = "danger";  content = "<strong>Oh snap!</strong> Change a few things up and try submitting again."; } }
        '';
      }}

      ${pageHeader "Progress bars"}
      ${templates.bootstrap.progress-bar { value = 60; }}
      ${templates.bootstrap.progress-bar { value = 40; type = "success"; }}
      ${templates.bootstrap.progress-bar { value = 20; type = "info"; }}
      ${templates.bootstrap.progress-bar { value = 60; type = "warning"; }}
      ${templates.bootstrap.progress-bar { value = 80; type = "danger"; }}
      ${templates.bootstrap.progress-bar { value = 60; type = "stripped"; }}
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = ''
          ''${templates.bootstrap.progress-bar { value = 60; }}
          ''${templates.bootstrap.progress-bar { value = 40; type = "success"; }}
          ''${templates.bootstrap.progress-bar { value = 20; type = "info"; }}
          ''${templates.bootstrap.progress-bar { value = 60; type = "warning"; }}
          ''${templates.bootstrap.progress-bar { value = 80; type = "danger"; }}
          ''${templates.bootstrap.progress-bar { value = 60; type = "stripped"; }}
        '';
      }}

      ${pageHeader "Panels"}
      <div class="row">
        <div class="col-sm-4">
          ${templates.bootstrap.panel {
            heading = ''<h3 class="panel-title">Panel title</h3>'';
            body    = "Panel content"; }}
          ${templates.bootstrap.panel {
            type    = "primary";
            heading = ''<h3 class="panel-title">Panel title</h3>'';
            body    = "Panel content"; }}
        </div><!-- /.col-sm-4 -->
        <div class="col-sm-4">
          ${templates.bootstrap.panel {
            type    = "success";
            heading = ''<h3 class="panel-title">Panel title</h3>'';
            body    = "Panel content"; }}
          ${templates.bootstrap.panel {
            type    = "info";
            heading = ''<h3 class="panel-title">Panel title</h3>'';
            body    = "Panel content"; }}
        </div><!-- /.col-sm-4 -->
        <div class="col-sm-4">
          ${templates.bootstrap.panel {
            type    = "warning";
            heading = ''<h3 class="panel-title">Panel title</h3>'';
            body    = "Panel content"; }}
          ${templates.bootstrap.panel {
            type    = "danger";
            heading = ''<h3 class="panel-title">Panel title</h3>'';
            body    = "Panel content"; }}
        </div><!-- /.col-sm-4 -->
      </div>
      <h4>Code</h4>
      ${templates.tag.codeblock {
        content = escapeHTML ''
          <div class="col-sm-4">
            ''${templates.bootstrap.panel {
              heading = '''<h3 class="panel-title">Panel title</h3>''';
              body    = "Panel content"; }}
            ''${templates.bootstrap.panel {
              type    = "primary";
              heading = '''<h3 class="panel-title">Panel title</h3>''';
              body    = "Panel content"; }}
          </div><!-- /.col-sm-4 -->
          <div class="col-sm-4">
            ''${templates.bootstrap.panel {
              type    = "success";
              heading = '''<h3 class="panel-title">Panel title</h3>''';
              body    = "Panel content"; }}
            ''${templates.bootstrap.panel {
              type    = "info";
              heading = '''<h3 class="panel-title">Panel title</h3>''';
              body    = "Panel content"; }}
          </div><!-- /.col-sm-4 -->
          <div class="col-sm-4">
            ''${templates.bootstrap.panel {
              type    = "warning";
              heading = '''<h3 class="panel-title">Panel title</h3>''';
              body    = "Panel content"; }}
            ''${templates.bootstrap.panel {
              type    = "danger";
              heading = '''<h3 class="panel-title">Panel title</h3>''';
              body    = "Panel content"; }}
          </div><!-- /.col-sm-4 -->
        '';
      }}
    </div> <!-- /container -->
  ''
)
