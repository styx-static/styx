{ conf, ... }:
let
  doctypes = {
    html4 = ''
      <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
        "http://www.w3.org/TR/html4/strict.dtd">
    '';
    html5 = ''
      <!DOCTYPE html>
    '';
    xhtml1 = ''
      <!DOCTYPE html PUBLIC
        "-//W3C//DTD XHTML 1.1//EN"
        "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
    '';
  };
in doctypes."${conf.theme.html.doctype}"
