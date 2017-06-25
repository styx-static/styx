{ lib }:
{
  id = "nix";
  name = "Nix";
  license = lib.licenses.mit;
  demoPage = https://styx-static.github.io/styx-theme-nix;
  homepage = https://github.com/styx-static/styx-theme-nix;
  tags = [ "minimal" ];
  screenshot = ./screen.png;
  description = ''
    Port of the https://github.com/LordMathis/hugo-theme-nix[nix] theme. +
    Requires the `generic-templates` theme.
  '';
}
