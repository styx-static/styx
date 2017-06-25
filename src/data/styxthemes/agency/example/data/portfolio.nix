{ lib, ... }@env:
with lib;
{
  id = "portfolio";
  title = "Portfolio";
  subtitle = "Lorem ipsum dolor sit amet consectetur.";

  items = loadDir { dir = ./projects; inherit env; };
}
