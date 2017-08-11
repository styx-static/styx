{ lib }:
{
  name = "Agency";
  id = "agency";
  license = lib.licenses.asl20;
  demoPage = https://styx-static.github.io/styx-theme-agency;
  homepage = https://github.com/styx-static/styx-theme-agency;
  screenshot = ./screen.png;
  documentation = lib.readFile ./documentation.adoc;
  description = ''
    Port of the https://github.com/digitalcraftsman/hugo-agency-theme[Agency] theme for Styx.
  '';
  longDescription = ''
    Originally made by https://github.com/digitalcraftsman[digitalcraftsman].

    https://github.com/digitalcraftsman/hugo-agency-theme[Original Theme]

    > Agency Theme is a one page portfolio for companies and freelancers based on the original Bootstrap theme by David Miller. This Hugo theme features several content sections, a responsive portfolio grid with hover effects, full page portfolio item modals, a timeline, and a contact form.
  '';
}
