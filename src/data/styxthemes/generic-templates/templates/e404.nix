{ lib, ... }:
lib.normalTemplate {
  content = ''
    <div>
      <h1>Page not found, Error 404</h1>
    </div>
  '';
  title = "404";
}
