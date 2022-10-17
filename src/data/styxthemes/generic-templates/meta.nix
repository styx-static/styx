{lib}:
with lib.lib; {
  id = "generic-templates";
  name = "Generic templates";
  license = licenses.mit;
  maintainers = with maintainers; [ericsagnes];
  demoPage = https://styx-static.github.io/styx-theme-generic-templates;
  homepage = https://github.com/styx-static/styx-theme-generic-templates;
  tags = ["generic-templates"];
  screenshot = ./screen.png;
  documentation = readFile ./documentation.adoc;
  description = "Generic theme providing a template framework and templates for http://getbootstrap.com/components/[bootstrap components].";
}
