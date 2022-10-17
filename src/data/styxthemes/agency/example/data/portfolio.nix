{lib, ...} @ env:
with lib.lib; {
  id = "portfolio";
  title = "Portfolio";
  subtitle = "Lorem ipsum dolor sit amet consectetur.";

  items = lib.data.loadDir {
    dir = ./projects;
    inherit env;
  };
}
