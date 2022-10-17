{
  inputs,
  cell,
}: {
  default = {
    description = "Minimal New Styx Site";
    path = ./presets/new-site;
  };
  sample-data = {
    description = "Sample pages & posts";
    path = ./presets/sample-data;
  };
}
