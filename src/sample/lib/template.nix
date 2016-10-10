# Template functions

lib:
with lib;
rec {

  /* Generate html tag attributes

       htmlAttr "class" "foo"
       => class="foo" (as a string)

       htmlAttr "class" [ "foo" "bar" ]
       => class="foo bar" (as a string)
  */
  htmlAttr = attrName: value:
    let
      value' = if isList value
               then concatStringsSep " " value
               else value;
    in "${attrName}=\"${value'}\"";

  /* Check if an href is pointing to an external domain
     Any href starting with http is considered external
  */
  isExternalHref = href: (match "^http.*" href) != null;

  /* Create a generator meta tag for Styx
  */
  generatorMeta = ''
    <meta name="generator" content="Styx" /> 
  '';

  /* Concat template functions with a new line
  */
  mapTemplate = concatMapStringsSep "\n";

  /* Concat template functions with a new line and pass an index
  */
  mapTemplateWithIndex = concatImapStringsSep "\n";

  /* Modulo
  */
  mod = a: b: a - (b*(a / b));

  /* Check if a number is odd
  */
  isOdd  = a: (mod a 2) == 1;

  /* Check if a number is even
  */
  isEven = a: (mod a 2) == 0;

  prettyTimestamp = timestamp:
    let
      year   = substring 0 4 timestamp;
      month' = substring 5 2 timestamp;
      day    = substring 8 2 timestamp;
      month  =
             if month' == "01" then "JAN"
        else if month' == "02" then "FEB"
        else if month' == "03" then "MAR"
        else if month' == "04" then "APR"
        else if month' == "05" then "MAY"
        else if month' == "06" then "JUN"
        else if month' == "07" then "JUL"
        else if month' == "08" then "AUG"
        else if month' == "09" then "SEP"
        else if month' == "10" then "OCT"
        else if month' == "11" then "NOV"
        else if month' == "12" then "DEC"
        else abort "Unknown month (${month'}) for date (${timestamp}).";
    in
      "${day} ${month} ${year}";

}
