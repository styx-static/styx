{ lib }:
{
  id = "hyde";
  name = "Hyde";
  license = lib.licenses.mit;
  demoPage = https://styx-static.github.io/styx-theme-hyde;
  homepage = https://github.com/styx-static/styx-theme-hyde;
  tags = [ "blog" ];
  screenshot = ./screen.png;
  description = ''
    Port of the https://github.com/poole/hyde[Hyde] theme. +
    Requires the `generic-templates` theme.
  '';
}
