env:

let template = { templates, ... }:
  args:
  ''
  <head>
  ${templates.partials.head.title-pre  args
  + templates.partials.head.title      args
  + templates.partials.head.title-post args
  }</head>
  '';

in with env.lib; documentedTemplate {
  description = ''
    Template responsible for `head` tag rendering. `head` is divided in the following templates:

    * <<templates.partials.head.title-pre>>
    ** <<templates.partials.head.meta>>
    * <<templates.partials.head.title>>
    * <<templates.partials.head.title-post>>
    ** <<templates.partials.head.feed>>
    ** <<templates.partials.head.css>>
    *** <<templates.lib.css.bootstrap>>
    *** <<templates.lib.css.font-awesome>>
    *** <<templates.partials.head.css-custom>>
    *** <<templates.partials.head.css-extra>>
    ** <<templates.partials.head.title-post-extra>>
  '';
  inherit env template;
}
