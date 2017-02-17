/* Take a screenshot of a site running on http://127.0.0.1:8080/
 */

var system = require('system');
var args = system.args;
var page = require('webpage').create();

var out = args[1];

page.viewportSize = {
    width:  1280,
    height:  800
};

page.open('http://127.0.0.1:8080/', function() {
    page.render(out);
    phantom.exit();
});
