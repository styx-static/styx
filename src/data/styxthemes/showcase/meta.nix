{ lib }:
{
  name = "showcase";
  license = lib.licenses.mit;
  maintainers = with lib.maintainers; [ ericsagnes ];
  demoPage = https://styx-static.github.io/styx-theme-showcase;
  homepage = https://github.com/styx-static/styx-theme-showcase;
  description = "A theme to show capabilities of Styx";
  longDescription = ''
    This is a theme for the Styx static site generator meant to show most of its functionalities with a basic design.
  '';
  tags = [ "generic-templates" ];
  screenshot = ./screen.png;
}
