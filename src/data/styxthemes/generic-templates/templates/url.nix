/* convert a path to a full url
*/
{ conf, ... }:
path:
"${conf.siteUrl}${path}"
