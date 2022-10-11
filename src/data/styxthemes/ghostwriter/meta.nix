{lib}: {
  id = "ghostwriter";
  name = "Ghostwriter";
  license = lib.licenses.mit;
  demoPage = https://styx-static.github.io/styx-theme-ghostwriter;
  homepage = https://github.com/styx-static/styx-theme-ghostwriter;
  tags = ["blog"];
  documentation = lib.readFile ./documentation.adoc;
  screenshot = ./screen.png;
  description = ''
    Port of the https://github.com/jbub/ghostwriter[Ghostwriter] theme. +
    Use the `generic-templates` theme.
  '';
}
